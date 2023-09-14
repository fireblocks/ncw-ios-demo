//
//  SignInRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn
import FireblocksSDK

class AuthRepository  {
    
    private let googleSignInManager = GoogleSignInManager()
    private let appleSignInManager = AppleSignInManager()
    
    func getGIDConfiguration() -> GIDConfiguration? {
        return googleSignInManager.getGIDConfiguration()
    }
    
    func getAppleRequest() -> ASAuthorizationAppleIDRequest {
        return appleSignInManager.getAppleRequest()
    }
    
    func signIn(with result: FirebaseAuthDelegate?, user: String, isSignIn: Bool) async -> AuthUser? {
        if await isSignInToFirebaseSucceed(with: result) {
            return await getAuthUserFromServer(user: user, isSignIn: isSignIn)
        } else {
            return nil
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
    
    private func getAuthUserFromServer(user: String, isSignIn: Bool) async -> AuthUser? {
        do {
            let userToken = await AuthRepository.getUserIdToken()
            let _ = try await SessionManager.shared.login()
            let devices = try await SessionManager.shared.getDevices()
            if let device = devices?.devices.last, isSignIn {
                let generatedDeviceId = device.deviceId
                return AuthUser(userToken: userToken, deviceId: generatedDeviceId, walletId: device.walletId)
            } else {
                let generatedDeviceId = FireblocksManager.shared.generateDeviceId()
                let result = try await SessionManager.shared.assign(deviceId:generatedDeviceId)
                return AuthUser(userToken: userToken, deviceId: generatedDeviceId, walletId: result.walletId)
            }
        } catch {
            print("AuthRepository, getAuthResponse() throws exception: \(error).")
            return nil
        }
    }
    
    static func getUserIdToken() async -> String {
        do {
            return try await Auth.auth().currentUser?.getIDToken() ?? ""
        } catch {
            print("AuthRepository, getUserIdToken() throws exception: \(error)")
            return ""
        }
    }
    
    static func getUserEmail() -> String {
        return Auth.auth().currentUser?.email ?? "-"
    }
}
