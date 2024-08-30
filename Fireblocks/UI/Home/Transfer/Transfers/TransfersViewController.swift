//
//  TransfersViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import UIKit

class TransfersViewController: UIViewController {

//MARK: - PROPERTIES
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(TransferCell.nib, forCellReuseIdentifier: TransferCell.nibName)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var notificationMessage: UILabel!
    @IBOutlet weak var refreshButton: AppActionBotton!
    
    let viewModel = TransfersViewModel.shared
    
//MARK: - LIFECYCLE functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        notificationView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notificationView.isHidden = true
    }
    
    @objc private func settingsTapped(){
        let vc = SettingsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func refreshTapped(_ sender: AppActionBotton) {
        notificationView.isHidden = true
    }
    
    func showNotificationView(type: NotificationType) {
        notificationView.isHidden = false
        notificationImage.image = type.getImage()
        notificationMessage.text = type.getMessage()
        
        refreshButton.isHidden = !type.isRefreshButtonNeeded()
        
        let refreshButtonImage = AssetsIcons.refresh.getIcon()
        refreshButton.config(title: "refresh", image: refreshButtonImage, style: .Primary)
    }
}

//MARK: - UITableViewDataSource
extension TransfersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTransfersCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransferCell.nibName, for: indexPath) as? TransferCell  else {
            return UITableViewCell()
        }
        
        let transfer = viewModel.getTransferFor(index: indexPath.row)
        cell.configCell(with: transfer)

        return cell
    } 
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
}

//MARK: - UITableViewDelegate
extension TransfersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TransferCell {
            UIView.animate(withDuration: 0.3, animations: {
                cell.setSelected(isSelected: true)
            },completion: { finished in
                UIView.animate(withDuration: 0.3) {
                    cell.setSelected(isSelected: false)
                }
                let vc = TransferDetailsViewController(withTransfer: self.viewModel.getTransferFor(index: indexPath.row), hideBackBarButton: false)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)

            })

        }
        
    }
}

//MARK: - TransfersViewModelDelegate
extension TransfersViewController: TransfersViewModelDelegate {
    func showNotification(type: NotificationType) {
        DispatchQueue.main.async { [weak self] in
            self?.showNotificationView(type: type)
        }
    }
    
    func transfersUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
