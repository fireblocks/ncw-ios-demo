//
//  SettingsViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 18/06/2023.
//

import UIKit
import UIKit
import SDWebImage
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    static let identifier = "SettingsViewController"
    
    var isDisableAdvancedFeatures = false
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    @IBOutlet weak var backupButton: SettingsOptionButton!
    @IBOutlet weak var recoverWalletButton: SettingsOptionButton!
    @IBOutlet weak var exportPrivateKeyButton: SettingsOptionButton!
    @IBOutlet weak var advancedInfoButton: SettingsOptionButton!
    
    private let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        displayUserData()
    }
    
    private func configureUI() {
        configureButtons()
        checkIfAdvancedFeaturesAvailable()
    }
    
    private func configureButtons() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
        
        backupButton.setData(
            title: LocalizableStrings.createABackup,
            icon: AssetsIcons.backup
        )
        
        recoverWalletButton.setData(
            title: LocalizableStrings.recoverWallet,
            icon: AssetsIcons.recover
        )
        exportPrivateKeyButton.setData(
            title: LocalizableStrings.exportPrivateKey,
            icon: AssetsIcons.key
        )
        advancedInfoButton.setData(
            title: LocalizableStrings.advancedInfo,
            icon: AssetsIcons.info
        )
    }
    
    @objc func handleCloseTap() {
        navigationController?.popViewController(animated: true)
    }

    private func checkIfAdvancedFeaturesAvailable() {
        if isDisableAdvancedFeatures {
            backupButton.disableView()
            exportPrivateKeyButton.disableView()
            advancedInfoButton.disableView()
        }
    }

    private func displayUserData() {
        displayUserProfileImage()
        displayUserFullName()
        displayUserEmail()
    }
    
    private func displayUserProfileImage() {
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.width / 2
        profilePictureImageView.clipsToBounds = true
        profilePictureImageView.sd_setImage(
            with: viewModel.getUrlOfProfilePicture(),
            placeholderImage: AssetsIcons.profilePlaceholder.getIcon()
        )
    }
    
    private func displayUserFullName() {
        userFullNameLabel.text = viewModel.getUserName()
    }
    
    private func displayUserEmail() {
        userEmailLabel.text = viewModel.getUserEmail()
    }
    
    @IBAction func backupTapped(_ sender: SettingsOptionButton) {
        navigateToBackupViewController()
    }
    
    @IBAction func recoverTapped(_ sender: Any) {
        navigateToRecoverViewController()
    }
    
    @IBAction func exportPrivateKeyTapped(_ sender: SettingsOptionButton) {
        navigateToTakeoverViewController()
    }
    
    @IBAction func advancedInfoTapped(_ sender: SettingsOptionButton) {
        navigateToAdvancedInfoViewController()
    }
    
    @IBAction func signOutTapped(_ button: UIButton) {
        showConfirmationBottomSheet()
    }
    
    private func navigateToBackupViewController() {
        if isDisableAdvancedFeatures {
            return
        }
        let vc = BackupViewController()
        vc.actionType = Backup(delegate: vc.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToRecoverViewController() {
        let vc = BackupViewController()
        vc.actionType = Recover(delegate: vc.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToTakeoverViewController() {
        if isDisableAdvancedFeatures {
            return
        }
        let vc = TakeoverViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAdvancedInfoViewController() {
        if isDisableAdvancedFeatures {
            return
        }
        let vc = AdvancedInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func popViewController(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func showConfirmationBottomSheet() {
        let bottomSheet = AreYouSureBottomSheet.Builder()
            .setUserActionDelegate(self)
            .setIcon(AssetsIcons.signOut)
            .setMessage(LocalizableStrings.singOutConfirmation)
            .setConfirmButtonTitle(LocalizableStrings.signOut)
            .build()
        
        navigationController?.present(bottomSheet, animated: true)
    }
    
    private func navigateToLogin() {
        if let window = view.window {
            let rootViewController = UINavigationController()
            let vc = AuthViewController()
            rootViewController.pushViewController(vc, animated: true)
            window.rootViewController = rootViewController
        }
    }
    
    @IBAction func shareLogsTapped(_ sender: UIButton) {
        self.createLogFile()
    }
}

extension SettingsViewController: UserActionDelegate {
    func confirmButtonClicked() {
        viewModel.stopPollingMessages()
        viewModel.signOutFromFirebase()
        navigateToLogin()
    }
}
