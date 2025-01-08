//
//  LoginViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import Foundation
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

enum LoginMethod: String, CaseIterable {
    case signIn
    case signUp
    case addDevice
}

protocol AuthViewModelDelegate {
    func isUserSignedIn(_ isUserSignedIn: Bool) async
}

final class AuthViewModel: ObservableObject {
    
    private let authRepository = AuthRepository()
    private var delegate: AuthViewModelDelegate?
    private var signInTask: Task<Void, Never>?
    private var loginMethod: LoginMethod = .signUp
    @Published var isSignedIn:Bool?
    
//    private var isSignIn = true
//    private var isAddingDevice = false

    init(_ delegate: AuthViewModelDelegate? = nil) {
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
//        signInTask = Task {
//            authRepository.isAddingDevice = loginMethod == .addDevice
//            guard let authUser = await authRepository.signIn(with: result, user: user, loginMethod: loginMethod) else {
//                await delegate?.isUserSignedIn(false)
//                await MainActor.run {
//                    isSignedIn = false
//                }
//
//                return
//            }
//            
//            let isSdkInitialized = FireblocksManager.shared.isInstanceInitialized(authUser: authUser)
//            await delegate?.isUserSignedIn(isSdkInitialized)
//            await MainActor.run {
//                isSignedIn = isSdkInitialized
//            }
//        }
    }
    
    func setLoginMethod(loginMethod: LoginMethod) {
        self.loginMethod = loginMethod
    }

    func getLoginMethod() -> LoginMethod {
        return loginMethod
    }
    
    func getErrorMessage() -> String {
        return loginMethod == .addDevice ? LocalizableStrings.addDeviceFailed : loginMethod == .signIn ? LocalizableStrings.signInFailed : LocalizableStrings.signUpFailed
    }
    
    func isUserHaveKeys() -> Bool {
        return  FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_ECDSA_SECP256K1) || FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_EDDSA_ED25519)
    }
    
    func isUserHaveAllKeys() -> Bool {
        return  FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_ECDSA_SECP256K1) && FireblocksManager.shared.isKeyInitialized(algorithm: .MPC_EDDSA_ED25519)
    }

}
