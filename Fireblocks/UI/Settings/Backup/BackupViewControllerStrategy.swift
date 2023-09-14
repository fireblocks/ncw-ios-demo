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
    var manuallyTitle: String { get }

    func performDriveAction(_ gidUser: GIDGoogleUser)
    func performICloudAction()
}

struct Backup: BackupViewControllerStrategy {
 
    let viewControllerTitle: String = LocalizableStrings.createKeyBackup
    let explanation: String = LocalizableStrings.backupExplanation
    let googleTitle: String = LocalizableStrings.backupOnDrive
    let iCloudTitle: String = LocalizableStrings.backupOnICloud
    let manuallyTitle: String = LocalizableStrings.backupManually
    
    private weak var delegate: BackupProviderDelegate?
    
    init(delegate: BackupProviderDelegate) {
        self.delegate = delegate
    }
    
    func performDriveAction(_ gidUser: GIDGoogleUser) {
        delegate?.backupToGoogleDrive(gidUser)
    }
    
    func performICloudAction() {
        delegate?.backupToICloud()
    }
}

struct Recover: BackupViewControllerStrategy {
    
    let viewControllerTitle: String = LocalizableStrings.recoverWalletTitle
    let explanation: String = LocalizableStrings.chooseRecoveryLocation
    let googleTitle: String = LocalizableStrings.recoverFromDrive
    let iCloudTitle: String = LocalizableStrings.recoverFromICloud
    let manuallyTitle: String = LocalizableStrings.recoverManually
    
    private weak var delegate: BackupProviderDelegate?

    init(delegate: BackupProviderDelegate) {
        self.delegate = delegate
    }
    
    func performDriveAction(_ gidUser: GIDGoogleUser) {
        delegate?.recoverFromGoogleDrive(gidUser)
    }
    
    func performICloudAction() {
        delegate?.recoverFromICLoud()
    }
}
