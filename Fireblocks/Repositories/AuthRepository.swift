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
        do {
            return try await Auth.auth().currentUser?.getIDToken()
        } catch {
            print("AuthRepository, getUserIdToken() throws exception: \(error)")
            return nil
        }
    }
    
    static func getUserEmail() -> String {
        return Auth.auth().currentUser?.email ?? "-"
    }
}
