//
//  MpcKeysViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import FireblocksSDK
import UIKit

class MpcKeysViewController: UIViewController {
    
    static let identifier = "MpcKeysViewController"
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var generateMpcKeysButton: AppActionBotton!
    @IBOutlet weak var footerButton: UIButton!

    private let viewModel = MpcKeysViewModel()
    private var alertView: AlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configUI()
        setNavigationControllerRightButton(icon: AssetsIcons.settings, action: #selector(navigateToSettings))
    }
    
    private func configUI(){
        self.navigationItem.title = LocalizableStrings.generateMPCKeys
        generateMpcKeysButton.config(title: LocalizableStrings.generateKeysButtonTitle, style: .Primary)
    }
    
    @IBAction func generateMpcKey(_ sender: AppActionBotton) {
        if !viewModel.didSucceedGenerateKeys {
            removeAlertView()
            showActivityIndicator(message: LocalizableStrings.generateKeysIndicatorMessage)
            viewModel.generateMpcKeys()
        } else {
            self.navigateCreateBackupScreen()
        }
    }
    
    @IBAction func navigateToSettings(_ sender: UIButton) {
        let vc = SettingsViewController()
        vc.isDisableAdvancedFeatures = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //Footer Button
    @IBAction func navigateToRecoverWallet(_ sender: UIButton){
        if !viewModel.didSucceedGenerateKeys {
            let vc = BackupViewController()
            vc.actionType = Recover(delegate: vc.self)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            self.navigateNextScreen()
        }
    }
    
    private func showErrorView(message: String){
        alertView = showAlert(
            description: message,
            isAnimationEnabled: false,
            bottomAnchor: generateMpcKeysButton.topAnchor
        )
    }
    
    private func removeAlertView(){
        guard let alertView = alertView else { return }
        alertView.removeFromSuperview()
    }
}

//MARK: - MpcKeysViewModelDelegate
extension MpcKeysViewController: MpcKeysViewModelDelegate {
    func navigateNextScreen() {
        let vc = TabBarViewController()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    func navigateCreateBackupScreen() {
        let vc = BackupViewController()
        vc.updateSourceView(didComeFromGenerateKeys: true)
        vc.actionType = Backup(delegate: vc.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func configSuccessUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideActivityIndicator()
            
            //TODO - text is needed
            self.navigationItem.title = LocalizableStrings.didGenerateMPCKeysSuccessTitle
            self.headerImageView.image = UIImage(named: "generateSuccess")
            
            self.headerLabel.text = "Congratulations!\nYou’ve successfully created your keys! Next, create a key backup to make sure you never lose key access."
            self.headerLabel.textAlignment = .center
            
            self.generateMpcKeysButton.config(title: LocalizableStrings.createKeyBackup, style: .Primary)
            self.footerButton.setTitle(LocalizableStrings.illDoThisLater, for: .normal)
        }


    }
    
    func showAlertMessage(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideActivityIndicator()
            
            self.showErrorView(message: message)
        }
    } 
}
