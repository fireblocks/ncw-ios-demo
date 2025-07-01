//
//  KeyStorageProvider.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 08/08/2023.
//

import Foundation
import LocalAuthentication
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

class KeyStorageProvider: KeyStorageDelegate {
    private let deviceId: String
    let context = LAContext()
    
    init(deviceId: String) {
        self.deviceId = deviceId
        context.touchIDAuthenticationAllowableReuseDuration = 15
    }
    
    enum Result {
        case loadSuccess(Data)
        case failure(OSStatus)
    }

    @available(*, deprecated, message: "Use remove(keyIds: Set<String>, callback: @escaping ([String : Bool]) -> ()) instead")
    func remove(keyId: String) {
        guard let acl = self.getAcl() else {
            return
        }
                
        var attributes = [String : AnyObject]()
        
        guard let tag = keyId.data(using: .utf8) else {
            return
        }

        attributes[kSecClass as String] = kSecClassKey
        attributes[kSecAttrApplicationTag as String] = tag as AnyObject
        attributes[kSecAttrAccessControl as String] = acl
        
        attributes[kSecUseAuthenticationContext as String] = context
        
        let status = SecItemDelete(attributes as CFDictionary)
        print(status)
        

    }
    
    func remove(keyIds: Set<String>, callback: @escaping ([String : Bool]) -> ())  {
        var dict: [String: Bool] = [:]

        guard let acl = self.getAcl() else {
            callback(dict)
            return
        }
                
        var attributes = [String : AnyObject]()
        
        for keyId in keyIds {
            if let tag = keyId.data(using: .utf8) {
                attributes[kSecClass as String] = kSecClassKey
                attributes[kSecAttrApplicationTag as String] = tag as AnyObject
                attributes[kSecAttrAccessControl as String] = acl
                
                attributes[kSecUseAuthenticationContext as String] = context
                
                let status = SecItemDelete(attributes as CFDictionary)
                print(status)
                dict[keyId] = status == errSecSuccess
            }
        }
        
        callback(dict)
    }

    
    func contains(keyIds: Set<String>, callback: @escaping ([String : Bool]) -> ())  {
        load(keyIds: keyIds) { privateKeys in
            var dict: [String: Bool] = [:]
            for key in keyIds {
                dict[key] = privateKeys[key] != nil
            }
            callback(dict)
        }
    }
    
    private func checkIfContainsKey(keyId: String) -> Bool {
        var error : Unmanaged<CFError>?
        guard let acl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                  [.userPresence],
                                                        &error) else {
            return false
        }

        
        var attributes = [String : AnyObject]()
        
        guard let tag = keyId.data(using: .utf8) else {
            return false
        }

        attributes[kSecClass as String] = kSecClassKey
        attributes[kSecAttrApplicationTag as String] = tag as AnyObject
        attributes[kSecAttrAccessControl as String] = acl
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne

        attributes[kSecUseAuthenticationContext as String] = context
        
        var resultEntry : AnyObject? = nil
        let status = SecItemCopyMatching(attributes as CFDictionary, &resultEntry)
        
        return status == errSecSuccess

    }

    func store(keys: [String : Data], callback: @escaping ([String : Bool]) -> ()) {
        AppLoggerManager.shared.logger()?.log("generateMpcKeys started store - keys: \(keys.keys)")
        biometricStatus { status in
            if status == .ready {
                self.saveToKeychain(keys: keys, callback: callback)
            } else {
                DispatchQueue.main.async {
                    AppLoggerManager.shared.logger()?.log("generateMpcKeys started store - biometric not ready")
                    callback([:])
                }
            }
        }

    }
    
    private func saveToKeychain(keys: [String : Data], callback: @escaping ([String : Bool]) -> ()) {
        guard let acl = self.getAcl() else {
            callback([:])
            return
        }
        
        var mpcSecretKeys: [String: Bool] = [:]
        
        var attributes = [String : AnyObject]()
        
        for (keyId, data) in keys {
            
            guard let tag = keyId.data(using: .utf8) else {
                continue
            }

            attributes[kSecClass as String] = kSecClassKey
            attributes[kSecAttrApplicationTag as String] = tag as AnyObject
            attributes[kSecValueData as String] = data as AnyObject
            attributes[kSecAttrAccessControl as String] = acl
            
            attributes[kSecUseAuthenticationContext as String] = context
            
            _ = SecItemDelete(attributes as CFDictionary)
            
            let status = SecItemAdd(attributes as CFDictionary, nil)
            if status == errSecSuccess {
                mpcSecretKeys[keyId] = true
            } else {
                mpcSecretKeys[keyId] = false
            }

        }
        
        AppLoggerManager.shared.logger()?.log("generateMpcKeys started store - keys stored: \(mpcSecretKeys)")
        callback(mpcSecretKeys)


    }
    
    func load(keyIds: Set<String>, callback: @escaping ([String : Data]) -> ()) {
        let startDate = Date()
//        DispatchQueue.main.async {
//            callback([:])
//        }
//        return;
        
        biometricStatus { status in
            if status == .ready {
                Task {
                    let keys = await self.getKeys(keyIds: keyIds)
                    DispatchQueue.main.async {
                        callback(keys)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    AppLoggerManager.shared.logger()?.log("generateMpcKeys started load - biometric not ready")
                    callback([:])
                }
            }
        }
    }
    
    private func getKeys(keyIds: Set<String>) async -> [String : Data] {
        var dict: [String: Data] = [:]
        let startDate = Date()
        guard let acl = self.getAcl() else {
            return [:]
        }

        for keyId in keyIds {
            let result = await getMpcSecret(keyId: keyId, acl: acl)
                switch result {
                case .loadSuccess(let data):
                    AppLoggerManager.shared.logger()?.log("generateMpcKeys started load - succeeded to load key: \(keyId)")
                    dict[keyId] = data
                case .failure(let failure):
                    AppLoggerManager.shared.logger()?.log("generateMpcKeys started load - failed to load key: \(keyId)")
                }
            
        }
        AppLoggerManager.shared.logger()?.log("generateMpcKeys started load - loaded keys: \(dict.keys)")
        return(dict)
    }
    
    private func getMpcSecret(keyId: String, acl: SecAccessControl) async -> Result {
        guard let tag = keyId.data(using: .utf8) else {
            AppLoggerManager.shared.logger()?.log("generateMpcKeys started load - failed not tag to load key: \(keyId)")
            return(.failure(errSecNotAvailable))
        }

        var attributes = [String : AnyObject]()

        attributes[kSecClass as String] = kSecClassKey
        attributes[kSecAttrApplicationTag as String] = tag as AnyObject
        attributes[kSecReturnData as String] = kCFBooleanTrue
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne
        attributes[kSecAttrAccessControl as String] = acl
        
        attributes[kSecUseAuthenticationContext as String] = context
        
        var resultEntry : AnyObject? = nil
        let status = SecItemCopyMatching(attributes as CFDictionary, &resultEntry)

        if status == errSecSuccess,
            let data = resultEntry as? NSData {
            return(.loadSuccess(Data(referencing: data)))
        }
        return(.failure(status))

    }

    private func getAcl() -> SecAccessControl? {
        var error : Unmanaged<CFError>?
        var acl: SecAccessControl?

        acl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                              kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                              .biometryCurrentSet,
                                              &error)

        if error != nil {
            AppLoggerManager.shared.logger()?.error("generateMpcKeys started store - no acl")
            return nil
        }
        return acl!
    }

    enum BiometricStatus {
        case notSupported //No hardware on device
        case noPasscode //User need to setup passcode/enroll to touchId/FaceId
        case notEnrolled //User is not enrolled
        case canApprove //We need to ask for permission
        case notApproved //User canceled permission
        case locked
        case ready //User approved
    }

    private func setupBiometric(succeeded: @escaping (Bool) -> ()) {
        var error: NSError?
        if context.canEvaluatePolicy(
                LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                if let self {
                    DispatchQueue.main.async {
                        if success {
                            succeeded(true)
                        } else {
                            succeeded(false)
                        }
                    }
                }
            }
            
        } else {
            DispatchQueue.main.async {
                succeeded(false)
            }
        }
    }
    
    private func biometricStatus(status: @escaping (BiometricStatus) -> ()) {
        var error: NSError?
        if context.canEvaluatePolicy(
                LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                error: &error) {
            status(.ready)
        } else {
            // Device cannot use biometric authentication
            if let err = error {
                switch err.code {
                case LAError.Code.biometryNotEnrolled.rawValue:
                    status(.notEnrolled)
                case LAError.Code.passcodeNotSet.rawValue:
                    status(.noPasscode)
                case LAError.Code.biometryNotAvailable.rawValue:
                    status(.notApproved)
                case LAError.Code.biometryLockout.rawValue:
                    status(.locked)
                default:
                    status(.notApproved)
                }
            }
        }
    }

}
