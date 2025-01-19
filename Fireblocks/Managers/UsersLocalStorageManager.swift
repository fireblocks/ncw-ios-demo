//
//  UsersLocalStorageManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 08/08/2023.
//

import Foundation

class UsersLocalStorageManager: ObservableObject {
    let defaults = UserDefaults.standard

    static let shared = UsersLocalStorageManager()
    private init() {
    }
    
    func lastDeviceId(email: String) -> String? {
        return defaults.string(forKey: "\(email)-deviceId")
    }

    func setLastDeviceId(deviceId: String, email: String) {
        defaults.set(deviceId, forKey: "\(email)-deviceId")
    }

    func setAddDeviceTimer() {
        defaults.set(Date().timeIntervalSince1970, forKey: "addDeviceStartTimer")
    }

    func getAddDeviceTimer() -> Double? {
        defaults.double(forKey: "addDeviceStartTimer")
    }
    
    func setAuthProvider(value: String) {
        defaults.set(value, forKey: "authProvider")
    }

    func getAuthProvider() -> String? {
        defaults.string(forKey: "authProvider")
    }
    
    func resetAuthProvider() {
        defaults.removeObject(forKey: "authProvider")
    }
}
