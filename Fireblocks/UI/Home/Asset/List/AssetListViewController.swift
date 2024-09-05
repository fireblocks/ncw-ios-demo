//
//  AssetListViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit
import NVActivityIndicatorView
import SwiftUI

class AssetListViewController: UIViewController {
    
    private let headerHeight: CGFloat = 170
    private let cellHeight: CGFloat = 83

    //MARK: - PROPERTIES
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var refreshIndicator: NVActivityIndicatorView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var bottomErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(AssetViewCell.nib, forCellReuseIdentifier: AssetViewCell.nibName)
            tableView.delegate = self
            tableView.dataSource = self
            configureRefreshControl()
        }
    }
    
    
    let viewModel = AssetListViewModel.shared
    
    //MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.delegate = self
        viewModel.fetchAssets()
        viewModel.listenToTransferChanges()
        activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.refreshControl?.frame != nil {
            var frame = tableView.refreshControl!.frame
            frame.origin = CGPoint(x: (frame.width - 40)/2.0, y: (frame.height - 40)/2.0)
            frame.size = CGSize(width: 40, height: 40)
            
            refreshIndicator.frame = frame
        }
    }
    
    //MARK: - FUNCTIONS
    
    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .clear
        tableView.refreshControl?.backgroundColor = .clear
        refreshIndicator.translatesAutoresizingMaskIntoConstraints = true
        tableView.refreshControl?.addSubview(refreshIndicator)

        tableView.refreshControl?.addTarget(self, action: #selector(refreshAssets), for: .valueChanged)
        refreshIndicator.type = .circleStrokeSpin
        refreshIndicator.color = AssetsColors.primaryBlue.getColor()

    }
    
    private func configureView(){
        activityIndicator.type = .circleStrokeSpin
        activityIndicator.color = AssetsColors.primaryBlue.getColor()
    }
    
    @IBAction func settingsTapped(_ sender: UIButton){
        let vc = SettingsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToChooseAssetScreen(flowType: ChooseAssetFlowType) {
        let vc = ChooseAssetViewController(nibName: ChooseAssetViewController.identifier, bundle: nil)
        vc.viewModel.assets = self.viewModel.getAssets()
        vc.viewModel.chooseAssetFlowType = flowType
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func refreshAssets(){
        self.refreshIndicator.startAnimating()
        viewModel.fetchAssets()
    }

    private func showAlertView(message: String){
        showAlert(description: message, bottomAnchor: bottomErrorView.bottomAnchor)
    }

}

extension AssetListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = AssetHeaderUIView()
            header.setCurrenBalance(viewModel.getBalance())
            header.setDelegate(self)
            header.isButtonsEnabled(viewModel.getIsButtonsEnabled())
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return headerHeight
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getAssetsCount() + 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssetViewCell.nibName, for: indexPath) as? AssetViewCell else {
            return UITableViewCell()
        }
        
        if indexPath.section == 0 {
            return UITableViewCell()
        }
        
        let asset = viewModel.getAssets()[indexPath.section - 1]
        cell.configCellWith(asset: asset, section: indexPath.section - 1)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.getAssets().count > (indexPath.section - 1) {
            self.viewModel.toggleAssetExpanded(asset: viewModel.getAssets()[indexPath.section - 1], section: indexPath.section)
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 0
        }
        return UITableView.automaticDimension

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

extension AssetListViewController: AssetListViewModelDelegate {
    @MainActor
    func refreshData()  {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.refreshIndicator.stopAnimating()
        }
    }
    
    @MainActor
    func refreshSection(section: Int)  {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        
    }

    
    @MainActor
    func gotError()  {
        DispatchQueue.main.async {
            self.errorView.alpha = 0
            self.errorView.isHidden = false
            self.tableView.isScrollEnabled = false
            self.activityIndicator.stopAnimating()
            self.refreshIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()

            UIView.animate(withDuration: 0.3) {
                self.errorView.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.errorView.alpha = 0
                    }, completion: { finished in
                        self.errorView.isHidden = true
                        self.tableView.isScrollEnabled = true
                    })
                }

            }
        }
    }
    
    @MainActor
    func navigateToNextScreen(with asset: Asset){
        switch viewModel.chooseAssetFlowType {
        case .send:
            let vc = AmountToSendViewController(nibName: "AmountToSendViewController", bundle: nil)
            vc.viewModel.asset = asset
            vc.viewModel.asset.isExpanded = false
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case .receive:
            let vc = ReceiveViewController(nibName: "ReceiveViewController", bundle: nil)
            vc.viewModel.asset = asset
            vc.viewModel.asset.isExpanded = false
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension AssetListViewController: AssetHeaderDelegate {
    @objc func sendButtonTapped(){
        navigateToChooseAssetScreen(flowType: .send)
    }
    
    @objc func receiveButtonTapped(){
        navigateToChooseAssetScreen(flowType: .receive)
    }
    
    @objc func plusButtonTapped(){
        let vc = AddAssetsViewController(devideId: FireblocksManager.shared.getDeviceId(), delegate: self)
        let nc = UINavigationController(rootViewController: vc)
        nc.isModalInPresentation = true
        self.present(nc, animated: true)
    }
}

extension AssetListViewController: AssetViewCellDelegate {
    func didTapSend(index: Int) {
        viewModel.didTapSend(index: index)
    }
    
    func didTapReceive(index: Int) {
        viewModel.didTapReceive(index: index)
    }
    
    
}

extension AssetListViewController: AddAssetsViewControllerDelegate {
    func dismissAddAssets(addedAssets: [Asset], failedAssets: [Asset]) {
        self.dismiss(animated: true)
        if failedAssets.count > 0 {
            let prefix = failedAssets.count > 1 ? "The following assets were" : "The following asset was"
            var assets: String = ""
            failedAssets.forEach { asset in
                assets += " \(asset.symbol),"
            }
            assets.removeLast()
            self.showAlertView(message: "\(prefix) not added: \(assets).\nPlease try again\n")
        }
        if addedAssets.count > 0 {
            activityIndicator.startAnimating()
            refreshAssets()
        }
    }
}

