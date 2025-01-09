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
        var googleSignInManager: GoogleSignInManager?
        var appleSignInManager: AppleSignInManager?
        var fireblocksManager: FireblocksManager?
        var coordinator: Coordinator?

        @Published var isConnected: Bool = false
                
        func setup(authRepository: AuthRepository, loadingManager: LoadingManager, coordinator: Coordinator, fireblocksManager: FireblocksManager, googleSignInManager: GoogleSignInManager, appleSignInManager: AppleSignInManager) {
            self.authRepository = authRepository
            self.loadingManager = loadingManager
            self.coordinator = coordinator
            self.fireblocksManager = fireblocksManager
            self.googleSignInManager = googleSignInManager
            self.appleSignInManager = appleSignInManager
        }
        
        func signInWithGoogle() {
            guard let gidSignInConfig = googleSignInManager?.getGIDConfiguration() else {
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
            guard let request = appleSignInManager?.getAppleRequest() else {
                return
            }
            loadingManager.isLoading = true
            let authorizationController = ASAuthorizationController(
                authorizationRequests: [request]
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
                if isConnected {
                    await self.handleSuccessSignIn()
                }
                self.loadingManager.isLoading = false
            }
        }
        
        var userHasKeys: Bool {
            return FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_ECDSA_SECP256K1) || FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_EDDSA_ED25519)
        }
        
        func handleSuccessSignIn() async {
            fatalError("handleSuccessSignIn should be implemented on child class")
        }
    }
}


