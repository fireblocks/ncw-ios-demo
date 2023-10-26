//
//  BackupViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 03/07/2023.
//

import Foundation
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST_Drive
import FirebaseAuth
import CloudKit

protocol BackupDelegate: AnyObject {
    func isBackupSucceed(_ isSucceed: Bool)
    func isBackupExist(_ backupData: BackupData?)
    func isRecoverSucceed(_ isSucceed: Bool)
}

protocol BackupProviderDelegate: AnyObject {
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser)
    func backupToICloud()
    func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser)
    func recoverFromICLoud()
}

protocol UpdateBackupDelegate: AnyObject {
    func updateBackupToGoogleDrive()
    func updateBackupToICloud()
    func updateBackupToExternal()
}


private let googleDriveApiClientId = "CLIENT_ID"

class BackupViewModel {
    
    private let googleDriveScope = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
    private let repository = BackupRepository()
    private var task: Task<Void, Never>?
    private weak var delegate: BackupDelegate?
    private let actionType: BackupViewControllerStrategy
    var didComeFromGenerateKeys = false
    
    init(_ delegate: BackupDelegate, _ actionType: BackupViewControllerStrategy){
        self.delegate = delegate
        self.actionType = actionType
    }
    
    deinit {
        task?.cancel()
        task = nil
    }
    
    func checkIfBackupExist() {
        task = Task {
            let backupData = await repository.fetchBackupData()
            if backupData?.isBackedUp == false {
                delegate?.isBackupExist(nil)
            } else {
                delegate?.isBackupExist(backupData)
            }
        }
    }
    
    func getGidConfiguration() -> GIDConfiguration? {
        var configuration: GIDConfiguration? = nil
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let infoDict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            if let clientId = infoDict[googleDriveApiClientId] as? String {
                configuration = GIDConfiguration(clientID: clientId)
            }
        }
        
        return configuration
    }
    
    func getGoogleDriveScope() -> [String] {
        return googleDriveScope
    }
    
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser) {
        task = Task {
            let result = await repository.backupToGoogleDrive(gidUser: gidUser)
            delegate?.isBackupSucceed(result)
        }
    }
    
    func backupToICloud() {
        task = Task {
            guard let container = await getCKContainer() else {
                delegate?.isBackupSucceed(false)
                return
            }
            
            let result = await repository.backupToICloud(container: container)
            delegate?.isBackupSucceed(result)
        }
    }
    
    func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser) {
        task = Task {
            let passPhrase = await repository.recoverFromGoogleDrive(gidUser: gidUser)
            let isSucceed = await recoverMpcKeys(passPhrase)
            delegate?.isRecoverSucceed(isSucceed)
        }
    }
    
    func recoverFromICloud() {
        task = Task {
            guard let container = await getCKContainer() else {
                delegate?.isBackupSucceed(false)
                return
            }
            
            let passPhrase = await repository.recoverFromICloud(container: container)
            let isSucceed = await recoverMpcKeys(passPhrase)
            delegate?.isRecoverSucceed(isSucceed)
        }
    }
    
    func getManuallyInputStrategy() async -> ManuallyInputViewControllerStrategy {
        if actionType is Backup {
            return await ManuallyBackup(inputContent: backupManually() ?? "")
        } else {
            return ManuallyRecover(inputContent: "")
        }
    }
    
    
    private func backupManually() async -> String? {
        return await repository.backupManually()
    }
    
    private func recoverMpcKeys(_ passPhrase: String) async -> Bool {
        return await FireblocksManager.shared.recoverWallet(recoverKey: passPhrase)
    }
    
    private func getCKContainer() async -> CKContainer? {
        do {
            let container = CKContainer.default()
            return try await container.accountStatus() == .available ? container : nil
        } catch {
            print("BackupViewModel, CKContainer account status throws: \(error).")
            return nil
        }
    }
}
