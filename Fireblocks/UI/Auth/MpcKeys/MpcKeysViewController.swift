//
//  MpcKeysViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

import UIKit
import SwiftUI
import FirebaseAuth

protocol MainSignOutDelegate: AnyObject {
    func didSignOut()
}

//class MpcKeysViewController: UIViewController {
//    
//    static let identifier = "MpcKeysViewController"
//    
//    @IBOutlet weak var headerImageView: UIImageView!
//    @IBOutlet weak var headerLabel: UILabel!
//    @IBOutlet weak var generateMpcKeysButton: AppActionBotton!
//    @IBOutlet weak var generateECDSAButton: AppActionBotton!
//    @IBOutlet weak var generateEDDSAButton: AppActionBotton!
//    @IBOutlet weak var footerButton: AppActionBotton!
//
//    @IBOutlet weak var footerButtonTC: NSLayoutConstraint!
//    @IBOutlet weak var footerButtonHC: NSLayoutConstraint!
//    private let viewModel: MpcKeysViewModel
//    private var alertView: AlertView?
//    
//    init() {
//        self.viewModel = MpcKeysViewModel()
//        super.init (nibName: "MpcKeysViewController", bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewModel.delegate = self
//        configUI()
//    }
//    
//    private func configUI(){
//        footerButtonHC.constant = 0
//        footerButtonTC.constant = 0
//
//        self.navigationItem.title = LocalizableStrings.generateMPCKeys
//        headerImageView.image = AssetsIcons.generateKeyImage.getIcon()
//        headerLabel.text = LocalizableStrings.mpcKeysGenertaeTitle
//        generateMpcKeysButton.config(title: LocalizableStrings.generateKeysButtonTitle, style: .Primary)
//        generateECDSAButton.config(title: "Generate EcDSA Key", style: .Primary)
//        generateEDDSAButton.config(title: "Generate EDDSA Key", style: .Primary)
//        footerButton.config(title: LocalizableStrings.illDoThisLater, style: .Transparent)
//        setNavigationControllerRightButton(icon: AssetsIcons.settings, action: #selector(navigateToSettings))
//        generateECDSAButton.isHidden = false
//        generateEDDSAButton.isHidden = false
//    }
//    
//    @IBAction func generateMpcKey(_ sender: AppActionBotton) {
//        if !viewModel.didSucceedGenerateKeys {
//            removeAlertView()
//            showActivityIndicator(message: LocalizableStrings.generateKeysIndicatorMessage)
//            viewModel.generateMpcKeys()
//        } else {
//            self.navigateCreateBackupScreen()
//        }
//    }
//    
//    @IBAction func generateECDSAKey(_ sender: AppActionBotton) {
//        if !viewModel.didSucceedGenerateKeys {
//            removeAlertView()
//            showActivityIndicator(message: LocalizableStrings.generateKeysIndicatorMessage)
//            viewModel.generateECDSAKeys()
//        } else {
//            self.navigateCreateBackupScreen()
//        }
//    }
//
//    @IBAction func generateEDDSAKey(_ sender: AppActionBotton) {
//        if !viewModel.didSucceedGenerateKeys {
//            removeAlertView()
//            showActivityIndicator(message: LocalizableStrings.generateKeysIndicatorMessage)
//            viewModel.generateEDDSAKeys()
//        } else {
//            self.navigateCreateBackupScreen()
//        }
//    }
//
//
//    @IBAction func didTapIllDoItLater(_ sender: AppActionBotton) {
//        navigateNextScreen()
//    }
//    
//    @objc func signOut() {
//        FireblocksManager.shared.signOut()
//    }
//    
//    @IBAction func navigateToSettings(_ sender: UIButton) {
//        let vc = SettingsViewController()
//        vc.isDisableAdvancedFeatures = true
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    //Footer Button
////    @IBAction func navigateToRecoverWallet(_ sender: UIButton){
////        if !viewModel.didSucceedGenerateKeys {
////            let vc = BackupViewController()
////            vc.actionType = Recover(delegate: vc.self)
////            navigationController?.pushViewController(vc, animated: true)
////        } else {
////            self.navigateNextScreen()
////        }
////    }
//    
//    private func showErrorView(message: String){
////        if viewModel.isAddingDevice {
////            setNavigationControllerRightButton(icon: AssetsIcons.close, action: #selector(signOut))
////        }
//        
//        alertView = showAlert(
//            description: message,
//            isAnimationEnabled: false,
//            bottomAnchor: generateMpcKeysButton.topAnchor
//        )
//    }
//    
//    private func removeAlertView(){
//        guard let alertView = alertView else { return }
//        alertView.removeFromSuperview()
//    }
//}
//
////MARK: - MpcKeysViewModelDelegate
//extension MpcKeysViewController: MpcKeysViewModelDelegate {
//    func navigateNextScreen() {
//        let vc = TabBarViewController()
//        self.navigationController?.setViewControllers([vc], animated: true)
//    }
//    
//    func navigateCreateBackupScreen() {
//        let vc = BackupViewController()
//        vc.updateSourceView(didComeFromGenerateKeys: true)
//        vc.actionType = Backup(delegate: vc.self)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    func configSuccessUI() {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.hideActivityIndicator()
//            
//            self.navigationItem.title = LocalizableStrings.didGenerateMPCKeysSuccessTitle
//            self.headerImageView.image = UIImage(named: "generateSuccess")
//            
//            self.headerLabel.text = "You’ve successfully created your keys! Next, create a key backup to make sure you never lose key access."
//            self.headerLabel.textAlignment = .center
//            
//            generateECDSAButton.isHidden = true
//            generateEDDSAButton.isHidden = true
//            self.generateMpcKeysButton.config(title: LocalizableStrings.createKeyBackup, style: .Primary)
//            self.footerButton.config(title: LocalizableStrings.illDoThisLater, style: .Transparent)
//            self.footerButtonHC.constant = 50
//            self.footerButtonTC.constant = 8
//        }
//
//
//    }
//    
//    func showAlertMessage(message: String) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.hideActivityIndicator()
//            
//            self.showErrorView(message: message)
//        }
//    }
//    
//    
//}
//
//extension MpcKeysViewController: QRCodeScannerViewControllerDelegate {
//    func gotAddress(address: String) {
//        print("")
//    }
//}
//
//extension MpcKeysViewController: MainSignOutDelegate {
//    func didSignOut() {
//        DispatchQueue.main.async {
//            self.signOut()
//        }
//    }
//}
