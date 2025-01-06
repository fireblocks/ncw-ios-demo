//
//  SignInViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

extension SignInView {
    
    class ViewModel: NSObject, ASAuthorizationControllerDelegate,
                     ASAuthorizationControllerPresentationContextProviding, ObservableObject {
        private var authRepository: AuthRepository!
        private var loadingManager: LoadingManager!
        private let googleSignInManager = GoogleSignInManager()
        private let appleSignInManager = AppleSignInManager()

        @Published var isConnected: Bool = false
        
        func setup(authRepository: AuthRepository, loadingManager: LoadingManager) {
            self.authRepository = authRepository
            self.loadingManager = loadingManager
        }
        
        func signInWithGoogle() {
            guard let gidSignInConfig = googleSignInManager.getGIDConfiguration() else {
                print("Can't create GIDSignIn config for google request.")
                return
            }
            
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                return
            }

            GIDSignIn.sharedInstance.configuration = gidSignInConfig
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [unowned self] result, error in
                guard error == nil else {
                    print("Sign in failed with: \(String(describing: error?.localizedDescription)).")
                    return
                }
                self.loadingManager.isLoading = true
                if let user = result?.user.userID {
                    self.signInToFirebase(with: result, user: user)
                } else {
                    self.loadingManager.isLoading = false
                }
            }
        }
        
        func signInWithApple() {
            loadingManager.isLoading = true
            let authorizationController = ASAuthorizationController(
                authorizationRequests: [appleSignInManager.getAppleRequest()]
            )
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                signInToFirebase(with: authorization, user: appleIDCredential.user)
            }
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            loadingManager.isLoading = false
            print("Sign in with Apple errored: \(error)")
        }
        
        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                return ASPresentationAnchor()
            }
            
            return presentingViewController.view.window!
        }
        
        private func signInToFirebase(with result: FirebaseAuthDelegate?, user: String) {
            Task {
                self.isConnected = await self.authRepository.signInToFirebase(with: result, user: user)
                self.loadingManager.isLoading = false
            }
        }

    }
    
    
}

