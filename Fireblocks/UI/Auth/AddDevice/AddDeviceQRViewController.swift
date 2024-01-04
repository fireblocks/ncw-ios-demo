//
//  AddDeviceQRViewController.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import FireblocksSDK
import UIKit

class AddDeviceQRViewController: UIViewController {
    
    static let identifier = "AddDeviceQRViewController"
    
    private let viewModel: AddDeviceQRViewModel
    
    init(requestId: String, email: String) {
        self.viewModel = AddDeviceQRViewModel(requestId: requestId, email: email)
        super.init (nibName: "AddDeviceQRViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setNavigationControllerRightButton(icon: AssetsIcons.close, action: #selector(stopTask))
    }
    
    private func configUI(){
        self.navigationItem.title = LocalizableStrings.mpcKeysAddDeviceHeader
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @objc func stopTask() {
        
    }
}
