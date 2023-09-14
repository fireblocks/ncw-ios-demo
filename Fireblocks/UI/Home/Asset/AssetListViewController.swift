//
//  AssetListViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit
import NVActivityIndicatorView

class AssetListViewController: UIViewController {
    
    private let headerHeight: CGFloat = 240
    
    //MARK: - PROPERTIES
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var errorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.register(AssetViewCell.nib, forCellReuseIdentifier: AssetViewCell.nibName)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    let viewModel = AssetListViewModel.shared
    
    //MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.delegate = self
        viewModel.fetchAssets()
        activityIndicator.startAnimating()
    }
    
    //MARK: - FUNCTIONS
    private func configureView(){
        errorTopConstraint.constant = headerHeight
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
}

extension AssetListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = AssetHeaderUIView()
        header.setCurrenBalance(viewModel.getBalance())
        header.setDelegate(self)
        header.isButtonsEnabled(viewModel.getIsButtonsEnabled())
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAssetsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AssetViewCell.nibName, for: indexPath) as? AssetViewCell else {
            return UITableViewCell()
        }
        
        let asset = viewModel.getAssets()[indexPath.row]
        cell.configCellWith(asset: asset)
        
        return cell
    }
}

extension AssetListViewController: AssetListViewModelDelegate {
    @MainActor
    func refreshData()  {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    @MainActor
    func gotError()  {
        self.errorView.isHidden = false
        self.tableView.isScrollEnabled = false
        self.activityIndicator.stopAnimating()
    }
}

extension AssetListViewController: AssetHeaderDelegate {
    @objc func sendButtonTapped(){
        navigateToChooseAssetScreen(flowType: .send)
    }
    
    @objc func receiveButtonTapped(){
        navigateToChooseAssetScreen(flowType: .receive)
    }
    
    @objc func refreshButtonTapped(){
        viewModel.fetchAssets()
        errorView.isHidden = true
        tableView.isScrollEnabled = true
        activityIndicator.startAnimating()
    }
}

