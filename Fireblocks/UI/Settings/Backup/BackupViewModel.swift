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
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String)
    func backupToICloud(passphraseId: String)
    func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser)
    func recoverFromICLoud()
}

protocol UpdateBackupDelegate: AnyObject {
    func updateBackupToGoogleDrive()
    func updateBackupToICloud()
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
    
    func getBackupDetails(backupData: BackupData) -> NSAttributedString {
        let backupDate = backupData.date ?? "-"
        let backupDetails = LocalizableStrings.backupDateAndAccount
            .replacingOccurrences(of: "{date}", with: backupDate)
            .replacingOccurrences(of: "{backup_provider}", with: backupData.title ?? "-")
        
        return makeSelectedTextBold(text: backupDetails, boldSubstring: backupDate)
    }

    private func makeSelectedTextBold(text: String, boldSubstring: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: boldSubstring)
        
        if range.location != NSNotFound {
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: range)
        }
        
        return attributedString
    }

    func getBackupInfo() async -> BackupInfo? {
        return await repository.getBackupInfo()
    }
    
    func getPassphraseInfo(location: BackupProvider) async -> PassphraseInfo {
        return await repository.getPassphraseInfos()?.passphrases.last ?? PassphraseInfo(passphraseId: FireblocksManager.shared.generatePassphraseId(), location: location)
    }
    
    func checkIfBackupExist() {
        task = Task {
            if let backupInfo = await getBackupInfo() {
                let backupData = BackupData(backupInfo: backupInfo)
                delegate?.isBackupExist(backupData)
            } else {
                delegate?.isBackupExist(nil)
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
    
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String) {
        task = Task {
            let result = await repository.backupToGoogleDrive(gidUser: gidUser, passphraseId: passphraseId)
            delegate?.isBackupSucceed(result)
        }
    }
    
    func backupToICloud(passphraseId: String) {
        task = Task {
            guard let container = await getCKContainer() else {
                delegate?.isBackupSucceed(false)
                return
            }
            
            let result = await repository.backupToICloud(container: container, passphraseId: passphraseId)
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
