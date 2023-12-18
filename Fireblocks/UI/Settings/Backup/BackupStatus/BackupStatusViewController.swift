//
//  BackupStatusViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 17/07/2023.
//

import UIKit

class BackupStatusViewController: UIViewController {
    private let viewModel: BackupStatusViewModel

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(didComeFromGenerateKeys: Bool) {
        self.viewModel = BackupStatusViewModel(didComeFromGenerateKeys: didComeFromGenerateKeys)
        super.init (nibName: "BackupStatusViewController", bundle: nil)
        self.navigationItem.setHidesBackButton(true, animated:true);
    }

    @IBAction func navigateToHomeTapped(_ sender: UIButton) {
        if viewModel.didComeFromGenerateKeys {
            let vc = TabBarViewController()
            self.navigationController?.setViewControllers([vc], animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
