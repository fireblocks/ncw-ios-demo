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
import SwiftUI

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
    @IBOutlet weak var addNewDeviceButton: SettingsOptionButton!
    @IBOutlet weak var generateKeysButton: SettingsOptionButton!
    @IBOutlet weak var shareLogsButton: SettingsOptionButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionLabelContainer: UIView!

    private let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        displayUserData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        versionLabelContainer.layer.cornerRadius = versionLabelContainer.frame.height/2.0
    }

    private func configureUI() {
        configureButtons()
        checkIfAdvancedFeaturesAvailable()
        versionLabel.text = Bundle.main.versionLabel
        versionLabelContainer.backgroundColor = AssetsColors.gray2.getColor()
    }
    
    private func configureButtons() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
        navigationItem.setHidesBackButton(true, animated: false)
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
        addNewDeviceButton.setData(
            title: LocalizableStrings.addNewDevice,
            icon: AssetsIcons.addNewDevice
        )
        shareLogsButton.setData(
            title: LocalizableStrings.shareLogs,
            icon: AssetsIcons.shareLogs
        )
        generateKeysButton.setData(
            title: LocalizableStrings.generateKeys,
            icon: AssetsIcons.key
        )

    }
    
    @objc func handleCloseTap() {
        navigationController?.popViewController(animated: true)
    }

    private func checkIfAdvancedFeaturesAvailable() {
        if isDisableAdvancedFeatures {
            backupButton.disableView()
            exportPrivateKeyButton.disableView()
//            advancedInfoButton.disableView()
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
    
    @IBAction func addNewDeviceTapped(_ sender: SettingsOptionButton) {
        navigateToAddDeviceViewController()
    }
    
    @IBAction func shareLogsTapped(_ sender: SettingsOptionButton) {
        self.createLogFile()
    }
    
    @IBAction func generateKeysTapped(_ sender: SettingsOptionButton) {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return
        }
        
        let view = NavigationContainerView {
            SpinnerViewContainer {
                GenerateKeysView()
            }
        }

        let vc = UIHostingController(rootView: view)

        UIView.animate(withDuration: 0.3) {
            window.rootViewController = vc
        }

    }

    
    @IBAction func signOutTapped(_ button: UIButton) {
        showConfirmationBottomSheet()
    }
    
    private func navigateToBackupViewController() {
        if isDisableAdvancedFeatures {
            return
        }
        
        let rootView = SpinnerViewContainer() {
            BackupWalletView(redirect: true)
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
        }
        let vc = UIHostingController(rootView: rootView)
        vc.navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToRecoverViewController() {
        let rootView = SpinnerViewContainer() {
            RecoverWalletView(redirect: false)
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
        }
        let vc = UIHostingController(rootView: rootView)
        vc.navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAddDeviceViewController() {
        let vc = PrepareForScanHostingVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    private func navigateToTakeoverViewController() {
        if isDisableAdvancedFeatures {
            return
        }
        let vc = TakeoverViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToAdvancedInfoViewController() {
//        if isDisableAdvancedFeatures {
//            return
//        }
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
            let rootViewController = UIHostingController(
                rootView: NavigationContainerView() {
                    LaunchView()
                        .environmentObject(SignInViewModel.shared)
                }
            )
            window.rootViewController = rootViewController
        }
    }
}

extension SettingsViewController: UserActionDelegate {
    func confirmButtonClicked() {
        viewModel.stopPollingMessages()
        viewModel.signOutFromFirebase()
        navigateToLogin()
    }
}
