//
//  BiometricsAuthentication.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit
import LocalAuthentication

class BiometricsAuthentication {
    
    private static let deniedAccessCode = -6
    private static let biometricsNotEnrolledCode = -7
    
    enum Error: LocalizedError {
        case invalidCredentials
        case deniedAccess
        case biometricsNotEnrolled
        case generalError
        case credentialsNotSaved
        
        var description: String {
            switch self{
            case .invalidCredentials:
                return LocalizableStrings.biometricsEmailOrPassIncorrectTryAgain
            case .deniedAccess:
                return LocalizableStrings.biometricsOpenSettingsToProvideAccess
            case .biometricsNotEnrolled:
                return LocalizableStrings.biometricsNotEnrolled
            case .generalError:
                return LocalizableStrings.biometricsFailedGeneral
            case .credentialsNotSaved:
                return LocalizableStrings.biometricsCredentialsNotSaved
            }
        }
    }
    
    enum SupportedType {
        case none
        case faceID
        case touchID
        
        var title: String {
            switch self {
            case .touchID:
                return LocalizableStrings.biometricsLoginWithTouchId
            case .faceID:
                return LocalizableStrings.biometricsLoginWithFaceId
            default:
                return ""
            }
        }
        
        var image: UIImage? {
            switch self {
            case .faceID:
                return UIImage(systemName: "faceid")
            case .touchID:
                return UIImage(systemName: "touchid")
            default:
                return nil
            }
        }
    }
    
    class func getSupportedType() -> SupportedType {
        let context = LAContext()
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType{
        case .none:
            return SupportedType.none
        case .touchID:
            return SupportedType.touchID
        case .faceID:
            return SupportedType.faceID
        @unknown default:
            return SupportedType.none
        }
    }
    
    // The method shows alert where user have to verify biometrics.
    class func requestUserToVerifyBiometrics(
        completion: @escaping (_ isAuthenticated: Bool, _ msg: String)-> Void
    ){
        // Checks if biometrics available
        var error: NSError?
        let context = LAContext()
        let isEvaluatedPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if let error = error {
            DispatchQueue.main.async {
                switch error.code {
                case deniedAccessCode:
                    completion(false, self.Error.deniedAccess.description)
                case biometricsNotEnrolledCode:
                    completion(false, self.Error.biometricsNotEnrolled.description)
                default:
                    completion(false, self.Error.generalError.description)
                }
            }
            return
        }
        
        if !isEvaluatedPolicy && context.biometryType == .none {
            DispatchQueue.main.async {
                completion(false, self.Error.generalError.description)
            }
            return
        }
        
        // If identification was succeed calls to completion with isAccessGranted.
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: LocalizableStrings.biometricsAccessExplanation,
            reply: {isAccessGranted, error in
                DispatchQueue.main.async {
                    if error != nil {
                        completion(false, self.Error.generalError.description)
                    }else{
                        completion(true, "")
                    }
                }
            }
        )
    }
}
