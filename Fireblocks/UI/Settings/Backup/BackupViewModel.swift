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
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

protocol BackupDelegate: AnyObject {
    func isBackupSucceed(_ isSucceed: Bool)
    func isBackupExist(_ backupData: BackupData?)
    func isRecoverSucceed(_ isSucceed: Bool)
}

protocol BackupProviderDelegate: AnyObject {
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String)
    func backupToICloud(passphraseId: String)
    func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String, callback: @escaping (String) -> ())
    func recoverFromICLoud()
}

protocol UpdateBackupDelegate: AnyObject {
    func updateBackupToGoogleDrive()
    func updateBackupToICloud()
}

protocol ResolveRecoverDelegate: AnyObject {
    func recover(passphraseId: String, provider: BackupProvider, callback: @escaping (String) -> ())
}

class BackupViewModel {
    
    private let googleDriveScope = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
    private let repository = BackupRepository()
    private var task: Task<Void, Never>?
    private weak var delegate: BackupDelegate?
    private weak var resolveRecoverDelegate: ResolveRecoverDelegate?
    private let actionType: BackupViewControllerStrategy
    var didComeFromGenerateKeys = false
    var recoverProvider: BackupProvider?
    
    init(_ delegate: BackupDelegate, _ actionType: BackupViewControllerStrategy, _ resolveRecoverDelegate: ResolveRecoverDelegate){
        self.delegate = delegate
        self.actionType = actionType
        self.resolveRecoverDelegate = resolveRecoverDelegate
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
        return GoogleDriveManager().getGidConfiguration()
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
    
    func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String, callback: @escaping (String) -> ()) {
        task = Task {
            let passphrase = await repository.recoverFromGoogleDrive(gidUser: gidUser, passphraseId: passphraseId)
            callback(passphrase)
        }
    }
    
    func recoverFromICloud(passphraseId: String, callback: @escaping (String) -> ()) {
        task = Task {
            guard let container = await getCKContainer() else {
                callback("")
                return
            }
            
            let passphrase = await repository.recoverFromICloud(container: container, passphraseId: passphraseId)
            callback(passphrase)
        }
    }
    
    func recoverMpcKeys(recoverProvider: BackupProvider) async -> Bool {
        self.recoverProvider = recoverProvider
        return await FireblocksManager.shared.recoverWallet(resolver: self)
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

extension BackupViewModel: FireblocksPassphraseResolver {
    func resolve(passphraseId: String, callback: @escaping (String) -> ()) {
        Task {
            if let recoverProvider  {
                switch recoverProvider {
                case .iCloud:
                    self.recoverFromICloud(passphraseId: passphraseId, callback: callback)
                case .GoogleDrive:
                    self.resolveRecoverDelegate?.recover(passphraseId: passphraseId, provider: recoverProvider, callback: callback)
                }
            } else {
                callback("")
            }
        }
    }
}

