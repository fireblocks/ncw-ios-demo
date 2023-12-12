//
//  BackupDetailsViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 16/07/2023.
//

import UIKit

class BackupDetailsViewController: UIViewController {

    @IBOutlet weak var backupDateAndAccountLabel: UILabel!
    @IBOutlet weak var backupAssociatedAccount: UILabel!
    
    private let viewModel = BackupDetailsViewModel()
    var backupData: BackupData?
    weak var delegate: UpdateBackupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setBackupData(backupData)
        setAccountAssociatedWithBackup()
        setBackupDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setAccountAssociatedWithBackup() {
        backupAssociatedAccount.text = viewModel.getAccountAssociatedWithLastBackup()
    }
    
    private func setBackupDetails() {
        backupDateAndAccountLabel.attributedText = viewModel.getBackupDetails()
    }
    
    @IBAction func updateKeyBackupTapped(_ any: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.popViewController(animated: true)
        }) { finished in
            if finished {
                if let location = self.backupData?.location {
                    if location == BackupProvider.GoogleDrive.rawValue {
                        self.delegate?.updateBackupToGoogleDrive()
                    } else if location == BackupProvider.iCloud.rawValue {
                        self.delegate?.updateBackupToICloud()
                    }
                }
            }
        }
    }
    
    @IBAction func changeKeyBackupLocationTapped(_ any: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
