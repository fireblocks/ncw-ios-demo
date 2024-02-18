//
//  UsersLocalStorageManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 08/08/2023.
//

import Foundation

class UsersLocalStorageManager: ObservableObject {
    private let defaults = UserDefaults.standard

    static let shared = UsersLocalStorageManager()
    private init() {
    }
    
    func backUpData(deviceId: String) -> BackupData? {
        do {
            if let data = UserDefaults.standard.data(forKey: "\(deviceId)-backupData") {
                let decoder = JSONDecoder()
                let backupData = try decoder.decode(BackupData.self, from: data)
                return backupData
            }
        } catch {
            print("Unable to Encode BackupData (\(error))")
        }
        return nil

    }

    func setBackUpData(deviceId: String, backupData: BackupData) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(backupData)
            defaults.set(data, forKey: "\(deviceId)-backupData")
        } catch {
            print("Unable to Encode BackupData (\(backupData))")
        }
    }

    func lastDeviceId(email: String) -> String? {
        return UserDefaults.standard.string(forKey: "\(email)-deviceId")
    }

    func setLastDeviceId(deviceId: String, email: String) {
        UserDefaults.standard.set(deviceId, forKey: "\(email)-deviceId")
    }

    func setAddDeviceTimer() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "addDeviceStartTimer")
    }

    func getAddDeviceTimer() -> Double? {
        UserDefaults.standard.double(forKey: "addDeviceStartTimer")
    }

}
