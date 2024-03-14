//
//  AuthType.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import Foundation

enum AuthType {
    case Google
    case iCloud
    
    func title(loginMethod: LoginMethod) -> String {
        switch self {
        case .Google:
            switch loginMethod {
            case .signIn:
                return LocalizableStrings.loginGoogleSignIn
            case .signUp:
                return LocalizableStrings.loginGoogleSignUp
            case .addDevice:
                return LocalizableStrings.loginGoogleAddDevice
            }
        case .iCloud:
            switch loginMethod {
            case .signIn:
                return LocalizableStrings.loginAppleSignIn

            case .signUp:
                return LocalizableStrings.loginAppleSignUP

            case .addDevice:
                return LocalizableStrings.loginAppleAddDevice
            }
        }
    }
}
