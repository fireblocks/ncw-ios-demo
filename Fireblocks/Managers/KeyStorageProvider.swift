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
    /// Stores the biometry type from when the class was initialized to detect changes
    private var storedBiometryType: LABiometryType?
    
    init(deviceId: String) {
        self.deviceId = deviceId
        context.touchIDAuthenticationAllowableReuseDuration = 15
        // Store initial biometry type to detect changes later
        self.storedBiometryType = getCurrentBiometryType()
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
        AppLoggerManager.shared.logger()?.log("store started - keys: \(keys.keys)")
        biometricStatus { status in
            switch status {
            case .ready:
                // Biometric authentication is available and ready - proceed with storage
                self.saveToKeychain(keys: keys, callback: callback)
            case .notEnrolled, .noPasscode, .notSupported, .locked, .changed, .notApproved, .canApprove:
                // Biometric authentication not available - error notification posted by biometricStatus method
                DispatchQueue.main.async {
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
            switch status {
            case .ready:
                // Biometric authentication is available and ready - proceed with loading
                Task {
                    let keys = await self.getKeys(keyIds: keyIds)
                    DispatchQueue.main.async {
                        callback(keys)
                    }
                }
            case .notEnrolled, .noPasscode, .notSupported, .locked, .changed, .notApproved, .canApprove:
                // Biometric authentication not available - error notification posted by biometricStatus method
                DispatchQueue.main.async {
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
                    AppLoggerManager.shared.logger()?.error("generateMpcKeys started load - failed to load key: \(keyId)")
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
        case notSupported    // No biometric hardware available on device
        case noPasscode      // User needs to setup device passcode first
        case notEnrolled     // User has not enrolled in Face ID/Touch ID
        case canApprove      // Biometrics available, need to ask for permission
        case notApproved     // User canceled permission or biometric not available
        case locked          // Biometric authentication locked due to failed attempts
        case ready           // Biometric authentication ready and approved
        case changed         // Biometric authentication has been modified/changed
    }
    
    /// Gets the current biometry type available on the device (Face ID, Touch ID, or none)
    /// - Returns: LABiometryType indicating the type of biometric authentication available
    private func getCurrentBiometryType() -> LABiometryType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        return context.biometryType
    }
    
    /// Checks if biometric authentication is currently enrolled and available
    /// - Returns: Boolean indicating whether biometric authentication can be used
    private func checkBiometricEnrollment() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Detects if the biometric authentication setup has changed in a concerning way since initialization
    /// This only flags changes that represent potential security issues, not initial enrollment
    /// - Returns: Boolean indicating whether biometric setup has changed in a concerning way
    private func hasBiometricChanged() -> Bool {
        let currentBiometryType = getCurrentBiometryType()
        
        // Check if there's a concerning change
        let hasConcerningChange: Bool
        
        if let storedType = storedBiometryType {
            // If we previously had biometrics enrolled and now it's different
            if storedType != .none && currentBiometryType != storedType {
                hasConcerningChange = true
            } else {
                // Going from .none to enrolled biometrics is good (first time setup)
                // Staying the same is also fine
                hasConcerningChange = false
            }
        } else {
            // No previous state recorded - not concerning
            hasConcerningChange = false
        }
        
        // Update stored type for future comparisons regardless of whether it's concerning
        storedBiometryType = currentBiometryType
        
        return hasConcerningChange
    }
    
    /// Posts a biometric error message via NotificationCenter for BaseFireblocksManager to handle
    /// - Parameters:
    ///   - title: Alert title text
    ///   - message: Alert message/description text
    private func postBiometricError(title: String, message: String) {
        let errorMessage = "\(title)\n\(message)"
        AppLoggerManager.shared.logger()?.error("KeyStorageProvider biometric error: \(title) - \(message)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: Notification.Name("BiometricError"), 
                object: nil, 
                userInfo: ["errorMessage": errorMessage]
            )
        }
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
    
    /// Evaluates the current biometric authentication status and posts error notifications
    /// This method performs comprehensive biometric status checking including change detection
    /// - Parameter status: Completion handler that receives the BiometricStatus result
    private func biometricStatus(status: @escaping (BiometricStatus) -> ()) {
        // First check if biometrics have changed since last check
        if hasBiometricChanged() {
            postBiometricError(title: "Biometric Authentication Changed", 
                             message: "Your biometric authentication has been modified. Please re-enroll your wallet for security.")
            status(.changed)
            return
        }
        
        var error: NSError?
        if context.canEvaluatePolicy(
                LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                error: &error) {
            // Biometric authentication is available and ready
            status(.ready)
        } else {
            // Device cannot use biometric authentication - determine the specific reason
            if let err = error {
                switch err.code {
                case LAError.Code.biometryNotEnrolled.rawValue:
                    // User has not enrolled in Face ID/Touch ID
                    postBiometricError(title: "Biometric Not Enrolled", 
                                     message: "Please set up Face ID or Touch ID in your device settings to secure your wallet.")
                    status(.notEnrolled)
                case LAError.Code.passcodeNotSet.rawValue:
                    // Device passcode must be set before biometric authentication
                    postBiometricError(title: "Passcode Required", 
                                     message: "Please set up a device passcode first, then enable biometric authentication.")
                    status(.noPasscode)
                case LAError.Code.biometryNotAvailable.rawValue:
                    // Biometric hardware not available or disabled
                    postBiometricError(title: "Biometric Authentication Unavailable", 
                                     message: "Biometric authentication is not available on this device.")
                    status(.notApproved)
                case LAError.Code.biometryLockout.rawValue:
                    // Too many failed biometric attempts - temporarily locked
                    postBiometricError(title: "Biometric Authentication Locked", 
                                     message: "Too many failed attempts. Please use your passcode to unlock.")
                    status(.locked)
                default:
                    // Other authentication errors
                    status(.notApproved)
                }
            } else {
                // No specific error but biometric not available
                postBiometricError(title: "Biometric Not Supported", 
                                 message: "This device does not support biometric authentication.")
                status(.notSupported)
            }
        }
    }

}
