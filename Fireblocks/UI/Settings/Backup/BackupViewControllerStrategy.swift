//
//  BackupStrategy.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 21/07/2023.
//

import Foundation
import CloudKit
import GoogleSignIn

protocol BackupViewControllerStrategy {
    var viewControllerTitle: String { get }
    var explanation: String { get }
    var googleTitle: String { get }
    var iCloudTitle: String { get }
    var tryAgainTitle: String { get }

    func performDriveAction(_ gidUser: GIDGoogleUser, passphraseId: String, callback: @escaping (String) -> ())
    func performICloudAction(passphraseId: String)
}

struct Backup: BackupViewControllerStrategy {
 
    let viewControllerTitle: String = LocalizableStrings.createKeyBackup
    let explanation: String = LocalizableStrings.backupExplanation
    let googleTitle: String = LocalizableStrings.backupOnDrive
    let iCloudTitle: String = LocalizableStrings.backupOnICloud
    let tryAgainTitle: String = LocalizableStrings.tryAgain

    private weak var delegate: BackupProviderDelegate?
    
    init(delegate: BackupProviderDelegate) {
        self.delegate = delegate
    }
    
    func performDriveAction(_ gidUser: GIDGoogleUser, passphraseId: String, callback: @escaping (String) -> ()) {
        delegate?.backupToGoogleDrive(gidUser, passphraseId: passphraseId)
    }
    
    func performICloudAction(passphraseId: String) {
        delegate?.backupToICloud(passphraseId: passphraseId)
    }
}
