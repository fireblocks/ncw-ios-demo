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
    
    func getBackupInfo() async -> BackupInfo? {
        let walletId = FireblocksManager.shared.getWalletId()
        let info = try? await SessionManager.shared.getLatestBackupInfo(walletId: walletId)
        return info
    }
    
    func getPassphraseInfos() async -> PassphraseInfos? {
        return try? await SessionManager.shared.getPassphraseInfos()
    }
    
    // MARK: Backup
    
    func backupToGoogleDrive(gidUser: GIDGoogleUser, passphraseId: String) async -> Bool {
        let passphrase = await GoogleDriveManager().recoverFromDrive(gidUser: gidUser, passphraseId: passphraseId) ?? FireblocksManager.shared.generatePassphrase()
        let isSucceeded = await GoogleDriveManager().backupToDrive(gidUser: gidUser, passphrase: passphrase, passphraseId: passphraseId)
        if isSucceeded {
            do {
                try await SessionManager.shared.createPassphraseInfo(passphraseInfo: PassphraseInfoBody(passphraseId: passphraseId, location: BackupProvider.GoogleDrive.rawValue))
                return await backupKeys(passphrase: passphrase, passphraseId: passphraseId, backupProvider: .GoogleDrive)
            } catch {
                print("BackupRepository, backupToGoogleDrive: failed to create passphrase info \(error)")
            }
        }

        print("BackupRepository, backupToGoogleDrive: failed to backup passphrase")
        return false
        
    }
    
    func backupToICloud(container: CKContainer, passphraseId: String) async -> Bool {
//        let passphrase = await ICloudManager().fetchData(container: container, passphraseId: passphraseId) ?? FireblocksManager.shared.generatePassphrase()
        let passphrase = FireblocksManager.shared.generatePassphrase()
        let isSucceeded = await ICloudManager().uploadData(container: container, passPhrase: passphrase, passphraseId: passphraseId)
        if isSucceeded {
            do {
                try await SessionManager.shared.createPassphraseInfo(passphraseInfo: PassphraseInfoBody(passphraseId: passphraseId, location: BackupProvider.iCloud.rawValue))
                return await backupKeys(passphrase: passphrase, passphraseId: passphraseId, backupProvider: .iCloud)
            } catch {
                print("BackupRepository, backupToICloud: failed to create passphrase info \(error)")
            }
        }
        
        print("BackupRepository, backupToICloud: failed to backup passphrase")
        return false

    }
    
    private func backupKeys(passphrase: String, passphraseId: String, backupProvider: BackupProvider) async -> Bool {
        if let backupKeys = await FireblocksManager.shared.backupKeys(passphrase: passphrase, passphraseId: passphraseId), backupKeys.count > 0 {
            if backupKeys.contains(where: {$0.keyBackupStatus != .SUCCESS}) {
                print("BackupRepository, \(backupProvider.rawValue): failed to backup keys")
            } else {
                print(backupKeys)
                print("BackupRepository, \(backupProvider.rawValue): succeeded")
                return true
            }
        }
        return false
    }
    
    // MARK: Recover
    
    func recoverFromGoogleDrive(gidUser: GIDGoogleUser, passphraseId: String) async -> String {
        return await GoogleDriveManager().recoverFromDrive(gidUser: gidUser, passphraseId: passphraseId) ?? ""
    }
    
    func recoverFromICloud(container: CKContainer, passphraseId: String) async -> String {
        return await ICloudManager().fetchData(container: container, passphraseId: passphraseId) ?? ""
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
