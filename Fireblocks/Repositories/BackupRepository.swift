//
//  UploadAppData.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import CloudKit
import Foundation
import GoogleSignIn

private typealias UserCredentials = (email: String, walletId: String, deviceId: String)

final public class BackupRepository {
    
    func fetchBackupData() async -> BackupData? {
        let userCredentials = await getUserCredentials()
        return UsersLocalStorageManager.shared.backUpData(deviceId: userCredentials.deviceId)
    }
    
    
    // MARK: Backup
    
    func backupToGoogleDrive(gidUser: GIDGoogleUser) async -> Bool {
        let passphrase = FireblocksManager.shared.generatePassphrase()
        let isSucceeded = await GoogleDriveManager().backupToDrive(gidUser: gidUser, passphrase: passphrase)
        if isSucceeded {
            if let backupKeys = await FireblocksManager.shared.backupKeys(passphrase: passphrase) {
                if backupKeys.contains(where: {$0.keyBackupStatus != .SUCCESS}) {
                    print("BackupRepository, backupToGoogleDrive: failed to backup keys")
                } else {
                    print(backupKeys)
                    await updateBackupRecordOnServer(backupProvider: .googleDrive)
                    return true
                }
            } else {
                print("BackupRepository, backupToGoogleDrive: failed to backup keys")
            }
        } else {
            print("BackupRepository, backupToGoogleDrive: failed to backup passphrase")
        }
        
        return false
        
    }
    
    func backupToICloud(container: CKContainer) async -> Bool {
        let passphrase = FireblocksManager.shared.generatePassphrase()
        let isSucceed = await ICloudManager().uploadData(container: container, passPhrase: passphrase)
        if isSucceed {
            if let backupKeys = await FireblocksManager.shared.backupKeys(passphrase: passphrase) {
                if backupKeys.contains(where: {$0.keyBackupStatus != .SUCCESS}) {
                    print("BackupRepository, backupToICloud: failed to backup keys")
                } else {
                    print(backupKeys)
                    await updateBackupRecordOnServer(backupProvider: .iCloud)
                    return true
                }
            } else {
                print("BackupRepository, backupToICloud: failed to backup keys")
            }
        } else {
            print("BackupRepository, backupToICloud: failed to backup passphrase")
        }
        
        return false

    }
    
    func backupManually() async -> String? {
        let passphrase = FireblocksManager.shared.generatePassphrase()
        if let backupKeys = await FireblocksManager.shared.backupKeys(passphrase: passphrase) {
            if backupKeys.contains(where: {$0.keyBackupStatus != .SUCCESS}) {
                print("BackupRepository, backupToICloud: failed to backup keys")
            } else {
                print(backupKeys)
                await updateBackupRecordOnServer(backupProvider: .external)
                return passphrase
            }
        } else {
            print("BackupRepository, backupToICloud: failed to backup keys")
        }
        return nil
    }
    
    func updateBackupRecordOnServer(backupProvider: BackupProvider) async {
        let userCredentials = await getUserCredentials()
        
        let backupData = BackupData(
            isBackedUp: true,
            email: userCredentials.email,
            date: getCurrentDate(),
            location: backupProvider.getValue()
        )
        
        UsersLocalStorageManager.shared.setBackUpData(deviceId: userCredentials.deviceId, backupData: backupData)
    }
    
    
    // MARK: Recover
    
    func recoverFromGoogleDrive(gidUser: GIDGoogleUser) async -> String {
        return await GoogleDriveManager().recoverFromDrive(gidUser: gidUser)
    }
    
    func recoverFromICloud(container: CKContainer) async -> String {
        return await ICloudManager().fetchData(container: container)
    }
    
    private func getUserCredentials() async -> UserCredentials {
        let email = AuthRepository.getUserEmail()
        let walletId = FireblocksManager.shared.getWalletId()
        let deviceId = FireblocksManager.shared.getDeviceId()
        return (email, walletId, deviceId)
    }
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
}
