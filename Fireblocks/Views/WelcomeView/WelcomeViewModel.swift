//
//  WelcomeViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import AuthenticationServices
import FireblocksSDK
import FirebaseAuth
import GoogleSignIn
import Foundation

protocol GoogleSignInProtocol {
    func googleSignIn()
}

protocol AppleSignInProtocol {
    func iCloudSignIn()
}

extension WelcomeView {
    class ViewModel: NSObject, ObservableObject {
        @Published var isMainPresented = true
        @Published var loginMethod: LoginMethod = .signUp
        @Published var showLoader = false
        @Published var offset = 168.0
        private var bannerErrorsManager: BannerErrorsManager?
        private var appRootManager: AppRootManager?

        private var signInTask: Task<Void, Never>?
        private var authRepository: AuthRepository?
        
        let bridge = BridgeVCView()

        var authType: AuthType? { 
            didSet {
                switch authType {
                case .Google:
                    googleSignIn()
                case .iCloud:
                    iCloudSignIn()
                case nil:
                    break
                }
            }
        }
        
        func mainButtonTapped(loginMethod: LoginMethod) {
            self.isMainPresented = false
            self.loginMethod = loginMethod
        }
        
        
        @MainActor
        func isUserSignedIn(_ isUserSignedIn: Bool) async {
            showLoader = false
            if isUserSignedIn {
                offset = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    switch self.loginMethod {
                    case .signIn:
                        if self.isUserHaveKeys() {
                            self.appRootManager?.currentRoot = .assets
                        } else {
                            self.appRootManager?.currentRoot = .noUser
                        }
                    case .signUp:
                        self.appRootManager?.currentRoot = .generateKeys
                    case .addDevice:
                        self.appRootManager?.currentRoot = .addDevice
                    }
                }
            } else {
                bannerErrorsManager?.errorMessage = loginMethod.getError()
            }
        }
        
        func setup(appRootManager: AppRootManager, authRepository: AuthRepository, bannerErrorsManager: BannerErrorsManager) {
            self.appRootManager = appRootManager
            self.authRepository = authRepository
            self.bannerErrorsManager = bannerErrorsManager
        }

        func isUserHaveKeys() -> Bool {
            return  FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_ECDSA_SECP256K1)
        }

    }
}

extension WelcomeView.ViewModel: GoogleSignInProtocol {
    func googleSignIn() {
        guard let gidSignInConfig = getGIDConfiguration() else {
            print("Can't create GIDSignIn config for google request.")
            return
        }
        
        showLoader = true

        GIDSignIn.sharedInstance.configuration = gidSignInConfig
        GIDSignIn.sharedInstance.signIn(withPresenting: bridge.vc) { [unowned self] result, error in
            guard error == nil else {
                showLoader = false
                print("Sign in failed with: \(String(describing: error?.localizedDescription)).")
                return
            }
            
            if let user = result?.user.userID {
                signInToFirebase(with: result, user: user)
            }
        }
    }

    private func getGIDConfiguration() -> GIDConfiguration? {
        return authRepository?.getGIDConfiguration()
    }

    private func signInToFirebase(with result: FirebaseAuthDelegate?, user: String) {
        signInTask = Task {
            authRepository?.isAddingDevice = loginMethod == .addDevice
            guard let authUser = await authRepository?.signIn(with: result, user: user, loginMethod: loginMethod) else {
                await self.isUserSignedIn(false)
                return
            }
            
            let isSdkInitialized = FireblocksManager.shared.isInstanceInitialized(authUser: authUser)

            await self.isUserSignedIn(isSdkInitialized)
        }
    }


}

extension WelcomeView.ViewModel: AppleSignInProtocol {
    func iCloudSignIn() {
        if let authRepository {
            let authorizationController = ASAuthorizationController(
                authorizationRequests: [getAppleRequest(authRepository: authRepository)]
            )
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    private func getAppleRequest(authRepository: AuthRepository) -> ASAuthorizationAppleIDRequest {
        return authRepository.getAppleRequest()
    }

}

extension WelcomeView.ViewModel:
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding
{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        showLoader = true
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            signInToFirebase(with: authorization, user: appleIDCredential.user)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

