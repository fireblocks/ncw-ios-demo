//
//  AppRootManager.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import Foundation

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: AppRoots = .login
    
    enum AppRoots {
        case login
        case noUser
        case addDevice
        case generateKeys
        case assets
    }
}
