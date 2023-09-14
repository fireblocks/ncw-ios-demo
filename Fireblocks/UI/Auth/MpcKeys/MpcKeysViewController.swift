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
    
    @IBOutlet weak var generateMpcKeysButton: AppActionBotton!
    
    private let viewModel = MpcKeysViewModel()
    private var alertView: AlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configUI()
        setNavigationControllerRightButton(icon: AssetsIcons.settings, action: #selector(navigateToSettings))
    }
    
    private func configUI(){
        self.navigationItem.title = "Generate MPC Keys"
        generateMpcKeysButton.config(title: LocalizableStrings.generateKeysButtonTitle, style: .Primary)
    }
    
    @IBAction func generateMpcKey(_ sender: AppActionBotton) {
        removeAlertView()
        showActivityIndicator(message: LocalizableStrings.generateKeysIndicatorMessage)
        viewModel.generateMpcKeys()
    }
    
    @IBAction func navigateToSettings(_ sender: UIButton) {
        let vc = SettingsViewController()
        vc.isDisableAdvancedFeatures = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func navigateToRecoverWallet(_ sender: UIButton){
        let vc = BackupViewController()
        vc.actionType = Recover(delegate: vc.self)
        navigationController?.pushViewController(vc, animated: true)
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideActivityIndicator()
            
            let vc = TabBarViewController()
            self.navigationController?.setViewControllers([vc], animated: true)
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
