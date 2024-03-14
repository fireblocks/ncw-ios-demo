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

class AuthRepository: ObservableObject  {
    
    private let googleSignInManager = GoogleSignInManager()
    private let appleSignInManager = AppleSignInManager()
    var isAddingDevice: Bool = false
    
    func getGIDConfiguration() -> GIDConfiguration? {
        return googleSignInManager.getGIDConfiguration()
    }
    
    func getAppleRequest() -> ASAuthorizationAppleIDRequest {
        return appleSignInManager.getAppleRequest()
    }
    
    func signIn(with result: FirebaseAuthDelegate?, user: String, loginMethod: LoginMethod) async -> AuthUser? {
        if await isSignInToFirebaseSucceed(with: result) {
            return await getAuthUserFromServer(user: user, loginMethod: loginMethod)
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
    
    private func getAuthUserFromServer(user: String, loginMethod: LoginMethod) async -> AuthUser? {
        do {
            let userToken = await AuthRepository.getUserIdToken()
            let _ = try await SessionManager.shared.login()
            guard let email = Auth.auth().currentUser?.email else {
                print("AuthRepository, getAuthResponse() throws exception: cannot get email address.")
                return nil
            }
            
            
            switch loginMethod {
            case .signUp:
                return try await signUp(userToken: userToken, email: email)
            case .signIn:
                return try await signIn(userToken: userToken, email: email)
            case .addDevice:
                return try await addDevice(userToken: userToken, email: email)
            }
            
        } catch {
            print("AuthRepository, getAuthResponse() throws exception: \(error).")
            return nil
        }
    }
    
    private func signUp(userToken: String, email: String) async throws -> AuthUser? {
        let generatedDeviceId = FireblocksManager.shared.generateDeviceId()
        UsersLocalStorageManager.shared.setLastDeviceId(deviceId: generatedDeviceId, email: email)
        let result = try await SessionManager.shared.assign(deviceId:generatedDeviceId)
        if let walletId = result.walletId {
            return AuthUser(userToken: userToken, deviceId: generatedDeviceId, walletId: walletId)
        } else {
            print("AuthRepository, getAuthResponse() throws exception: invalid assign response.")
            return nil
        }
    }
    
    private func signIn(userToken: String, email: String) async throws -> AuthUser? {
        if let deviceId = UsersLocalStorageManager.shared.lastDeviceId(email: email) {
            let result = try await SessionManager.shared.assign(deviceId:deviceId)
            if let walletId = result.walletId {
                return AuthUser(userToken: userToken, deviceId: deviceId, walletId: walletId)
            } else {
                print("AuthRepository, getAuthResponse() throws exception: invalid assign response.")
                return nil
            }
        }
        
        let devices = try await SessionManager.shared.getDevices()
        if let device = devices?.devices.last {
            if let deviceId = device.deviceId, !deviceId.isEmpty, let walletId = device.walletId, !walletId.isEmpty {
                let info = try await SessionManager.shared.getLatestBackupInfo(walletId: walletId)
                if let backedUpDeviceId = info.deviceId {
                    return AuthUser(userToken: userToken, deviceId: backedUpDeviceId, walletId: walletId)
                } else {
                    print("AuthRepository, getAuthResponse() throws exception: invalid GetDevicesResponse.")
                    return nil
                }
            } else {
                print("AuthRepository, getAuthResponse() throws exception: invalid GetDevicesResponse.")
                return nil
            }
        } else {
            print("AuthRepository, getAuthResponse() throws exception: invalid GetDevicesResponse.")
            return nil
        }
    }
    
    private func addDevice(userToken: String, email: String) async throws -> AuthUser? {
        let devices = try await SessionManager.shared.getDevices()
        if let device = devices?.devices.last {
            if let walletId = device.walletId, !walletId.isEmpty {
                let generatedDeviceId = FireblocksManager.shared.generateDeviceId()
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: generatedDeviceId, email: email)
                let result = try await SessionManager.shared.joinWallet(deviceId: generatedDeviceId, walletId: walletId)
                return AuthUser(userToken: userToken, deviceId: generatedDeviceId, walletId: walletId)
            } else {
                print("AuthRepository, getAuthResponse() throws exception: invalid GetDevicesResponse.")
                return nil
            }
        } else {
            print("AuthRepository, getAuthResponse() throws exception: invalid GetDevicesResponse.")
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
