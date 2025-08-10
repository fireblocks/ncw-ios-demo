//
//  SignInRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import Foundation
import FirebaseAuth
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

class AuthRepository  {
    
    func signInToFirebase(with result: FirebaseAuthDelegate?, user: String) async -> Bool {
        return await signIn(with: result, user: user)
    }
    
    func signIn(with result: FirebaseAuthDelegate?, user: String) async -> Bool {
        if await isSignInToFirebaseSucceed(with: result) {
            return true
        } else {
            return false
        }
    }
    
    private func isSignInToFirebaseSucceed(with result: FirebaseAuthDelegate?) async -> Bool {
        guard let credential = result?.getCredentials() else {
            return false
        }
        
        do {
            let _ = try await Auth.auth().signIn(with: credential)
            return true
        } catch {
            print("Firebase auth failed: \(error.localizedDescription).")
            return false
        }
    }
    
    static func getUserIdToken() async -> String? {
        return await getUserIdTokenWithRecovery(retryCount: 0)
    }
    
    private static func getUserIdTokenWithRecovery(retryCount: Int) async -> String? {
        let maxRetries = 2
        
        do {
            guard let currentUser = Auth.auth().currentUser else {
                AppLoggerManager.shared.logger()?.log("AuthRepository, getUserIdToken(): currentUser is null - user not authenticated")
                
                // Try to recover from nil currentUser
                if retryCount < maxRetries {
                    AppLoggerManager.shared.logger()?.log("AuthRepository, getUserIdToken(): Attempting auth state recovery, retry \(retryCount + 1)")
                    
                    // Wait a moment for Firebase Auth state to potentially restore
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    
                    // Check if auth state was restored
                    if Auth.auth().currentUser != nil {
                        return await getUserIdTokenWithRecovery(retryCount: retryCount + 1)
                    }
                    
                    // Try to trigger auth state listener update
                    return await waitForAuthStateRestore(retryCount: retryCount)
                }
                
                return nil
            }
            
            // First try to get cached token
            return try await currentUser.getIDToken()
        } catch {
            AppLoggerManager.shared.logger()?.log("AuthRepository, getUserIdToken() throws exception: \(error), trying force refresh")
            
            // If getting cached token fails, force refresh using completion handler
            guard let currentUser = Auth.auth().currentUser else {
                // If user became nil during execution, try recovery
                if retryCount < maxRetries {
                    return await getUserIdTokenWithRecovery(retryCount: retryCount + 1)
                }
                return nil
            }
            
            return await withCheckedContinuation { continuation in
                currentUser.getIDTokenForcingRefresh(true) { idToken, error in
                    if let error = error {
                        AppLoggerManager.shared.logger()?.log("AuthRepository, getUserIdToken() force refresh failed: \(error)")
                        continuation.resume(returning: nil)
                    } else {
                        AppLoggerManager.shared.logger()?.log("AuthRepository, getUserIdToken() force refresh succeeded")
                        continuation.resume(returning: idToken)
                    }
                }
            }
        }
    }
    
    private static func waitForAuthStateRestore(retryCount: Int) async -> String? {
        AppLoggerManager.shared.logger()?.log("AuthRepository, waitForAuthStateRestore(): Waiting for auth state to restore")
        
        return await withCheckedContinuation { continuation in
            var authStateListener: AuthStateDidChangeListenerHandle?
            var hasResumed = false
            
            // Set up a timeout
            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 second timeout
                if !hasResumed {
                    hasResumed = true
                    AppLoggerManager.shared.logger()?.log("AuthRepository, waitForAuthStateRestore(): Timeout waiting for auth state")
                    if let listener = authStateListener {
                        Auth.auth().removeStateDidChangeListener(listener)
                    }
                    continuation.resume(returning: nil)
                }
            }
            
            // Listen for auth state changes
            authStateListener = Auth.auth().addStateDidChangeListener { auth, user in
                if !hasResumed {
                    hasResumed = true
                    timeoutTask.cancel()
                    
                    if let listener = authStateListener {
                        Auth.auth().removeStateDidChangeListener(listener)
                    }
                    
                    if let user = user {
                        AppLoggerManager.shared.logger()?.log("AuthRepository, waitForAuthStateRestore(): Auth state restored for user: \(user.email ?? "unknown")")
                        // Recursively try to get token now that user is back
                        Task {
                            let token = await getUserIdTokenWithRecovery(retryCount: retryCount + 1)
                            continuation.resume(returning: token)
                        }
                    } else {
                        AppLoggerManager.shared.logger()?.log("AuthRepository, waitForAuthStateRestore(): Auth state changed but user is still nil")
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    static func getUserEmail() -> String {
        return Auth.auth().currentUser?.email ?? "-"
    }
    
    /// Checks if user is currently authenticated
    static func isUserAuthenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Signs out the current user
    static func signOut() {
        do {
            try Auth.auth().signOut()
            AppLoggerManager.shared.logger()?.log("AuthRepository: User signed out successfully")
        } catch {
            AppLoggerManager.shared.logger()?.log("AuthRepository: Sign out failed: \(error)")
        }
    }
    
    /// Checks if the current user has been deleted from Firebase
    static func isUserDeleted() async -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            return false
        }
        
        do {
            // Try to get ID token to check user status
            let _ = try await currentUser.getIDToken()
            return false
        } catch {
            // Check if the error is specifically the user not found error
            let nsError = error as NSError
            return nsError.domain == "FIRAuthErrorDomain" && nsError.code == 17011
        }
    }
}
