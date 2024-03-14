//
//  LoginMethod.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import Foundation

enum LoginMethod: String, CaseIterable {
    case signIn
    case signUp
    case addDevice
    
    func subtitle() -> String {
        switch self {
        case .signIn:
            return LocalizableStrings.signInTitle
        case .signUp:
            return LocalizableStrings.signUpTitle
        case .addDevice:
            return LocalizableStrings.addDeviceTitle
        }
    }
    
    func getError() -> String {
        switch self {
        case .signIn:
            return LocalizableStrings.signInFailed
        case .signUp:
            return LocalizableStrings.signUpFailed
        case .addDevice:
            return LocalizableStrings.addDeviceFailed
        }
    }
}
