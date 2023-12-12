//
//  BackupViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST_Drive
import FirebaseAuth
import CloudKit

class BackupViewController: UIViewController{
    
    static let identifier = "BackupViewController"
    
    lazy var actionType: BackupViewControllerStrategy = { Backup(delegate: self) }()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backupDateAndAccountLabel: UILabel!
    @IBOutlet weak var backupDateAndAccountLabelHC: NSLayoutConstraint!
    @IBOutlet weak var googleDriveButton: AppActionBotton!
    @IBOutlet weak var iCloudButton: AppActionBotton!
    
    private lazy var viewModel = { BackupViewModel(self, actionType) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfBackupExist()
        configureUI()
    }
    
    func updateSourceView(didComeFromGenerateKeys: Bool = false) {
        viewModel.didComeFromGenerateKeys = didComeFromGenerateKeys
    }
    
    private func checkIfBackupExist() {
        if actionType is Backup {
            showActivityIndicator()
            viewModel.checkIfBackupExist()
        }
    }
    
    private func configureUI() {
        self.navigationItem.title = actionType.viewControllerTitle
        titleLabel.text = actionType.explanation
        googleDriveButton.config(title: actionType.googleTitle, image: AssetsIcons.googleIcon.getIcon(), style: .Secondary)
        iCloudButton.config(title: actionType.iCloudTitle, image: AssetsIcons.appleIcon.getIcon(), style: .Secondary)
    }
    
    @IBAction func driveBackupTapped(_ sender: AppActionBotton) {
        showActivityIndicator()
        Task {
            let passphraseInfo = await viewModel.getPassphraseInfo(location: .GoogleDrive)
            authenticateUser(passphraseId: passphraseInfo.passphraseId)
        }
    }
    
    @IBAction func iCloudBackupTapped(_ sender: AppActionBotton) {
        showActivityIndicator()
        Task {
            let passphraseInfo = await viewModel.getPassphraseInfo(location: .iCloud)
            actionType.performICloudAction(passphraseId: passphraseInfo.passphraseId)
        }
    }
    
    @IBAction func goBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func authenticateUser(passphraseId: String) {
        guard let gidConfig = viewModel.getGidConfiguration() else {
            print("❌ BackupViewController, gidConfig is nil.")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = gidConfig
        GIDSignIn.sharedInstance.signIn(
            withPresenting: self,
            hint: nil,
            additionalScopes: viewModel.getGoogleDriveScope()
        ) { [unowned self] result, error in
            
            guard error == nil else {
                hideActivityIndicator()
                print("Authentication failed with: \(String(describing: error?.localizedDescription)).")
                return
            }
            
            guard let gidUser = result?.user else {
                hideActivityIndicator()
                print("GIDGoogleUser is nil")
                return
            }
            
            actionType.performDriveAction(gidUser, passphraseId: passphraseId)
        }
    }
    
    private func navigateToBackupStatusViewController() {
        let vc = BackupStatusViewController(didComeFromGenerateKeys: viewModel.didComeFromGenerateKeys)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAssetsViewController() {
        if let window = view.window {
            let rootViewController = UINavigationController()
            let vc = TabBarViewController()
            rootViewController.pushViewController(vc, animated: true)
            window.rootViewController = rootViewController
        }
        
    }
    
    private func showError(message: String) {
        showAlert(description: message, edgePadding: 16)
    }
}

extension BackupViewController: BackupDelegate {
    func isBackupExist(_ backupData: BackupData?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.hideActivityIndicator()
            if let backupData = backupData {
                UIView.animate(withDuration: 0.3) {
                    self.titleLabel.attributedText = self.viewModel.getBackupDetails(backupData: backupData)
                }
            }
        }
    }
    
    func isBackupSucceed(_ isSucceed: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.hideActivityIndicator()
            if isSucceed {
                self.navigateToBackupStatusViewController()
            } else {
                self.showError(message: LocalizableStrings.failedToCreateKeyBackup)
            }
        }
    }
    
    func isRecoverSucceed(_ isSucceed: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.hideActivityIndicator()
            if isSucceed {
                self.navigateToAssetsViewController()
            } else {
                self.showError(message: LocalizableStrings.failedToRecoverWallet)
            }
        }
    }
}

extension BackupViewController: BackupProviderDelegate {
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String) {
        showActivityIndicator()
        viewModel.backupToGoogleDrive(gidUser, passphraseId: passphraseId)
    }
    
    func backupToICloud(passphraseId: String) {
        showActivityIndicator()
        viewModel.backupToICloud(passphraseId: passphraseId)
    }
    
    func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser) {
        showActivityIndicator()
        viewModel.recoverFromGoogleDrive(gidUser)
    }
    
    func recoverFromICLoud() {
        showActivityIndicator()
        viewModel.recoverFromICloud()
    }
}

extension BackupViewController: UpdateBackupDelegate {
    func updateBackupToGoogleDrive() {
        Task {
            let passphraseInfo = await viewModel.getPassphraseInfo(location: .GoogleDrive)
            authenticateUser(passphraseId: passphraseInfo.passphraseId)
        }
    }
    
    func updateBackupToICloud() {
        iCloudBackupTapped(AppActionBotton())
    }
    
}

