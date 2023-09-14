//
//  LoginViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import AuthenticationServices
import FireblocksSDK
import FirebaseAuth
import GoogleSignIn
import Foundation

protocol AuthViewModelDelegate {
    func isUserSignedIn(_ isUserSignedIn: Bool) async
}

final class AuthViewModel {
    
    private let authRepository = AuthRepository()
    private let delegate: AuthViewModelDelegate
    private var signInTask: Task<Void, Never>?
    private var isSignIn = true
    
    init(_ delegate: AuthViewModelDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        signInTask?.cancel()
    }
    
    func getGIDConfiguration() -> GIDConfiguration? {
        return authRepository.getGIDConfiguration()
    }
    
    func getAppleRequest() -> ASAuthorizationAppleIDRequest {
        return authRepository.getAppleRequest()
    }
    
    func signInToFirebase(with result: FirebaseAuthDelegate?, user: String) {
        signInTask = Task {
            guard let authUser = await authRepository.signIn(with: result, user: user, isSignIn: isSignIn) else {
                await delegate.isUserSignedIn(false)
                return
            }
            
            let isSdkInitialized = FireblocksManager.shared.isInstanceInitialized(authUser: authUser)
            await delegate.isUserSignedIn(isSdkInitialized)
        }
    }
    
    func setSignIn(isSignIn: Bool) {
        self.isSignIn = isSignIn
    }
    
    func getSignIn() -> Bool {
        return isSignIn
    }
    
    func getErrorMessage() -> String {
        return isSignIn ? LocalizableStrings.signInFailed : LocalizableStrings.signUpFailed
    }
    
    func isUserHaveKeys() -> Bool {
        return  FireblocksManager.shared.isKeyInitialized()
    }
}
