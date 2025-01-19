//
//  File.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

import Foundation

extension UsersLocalStorageManager {
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

}
