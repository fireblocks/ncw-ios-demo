//
//  FeeRateViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 04/07/2023.
//

import UIKit
import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

protocol FeeRateViewModelDelegate: AnyObject {
    func refreshData()
    func isTransactionCreated(isCreated: Bool)
}

class FeeRateViewController: UIViewController, SwiftUIEnvironmentBridge {

//MARK: - PROPERTIES 
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(FeeRateCell.nib, forCellReuseIdentifier: FeeRateCell.nibName)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var createTransactionButton: AppActionBotton!
    
    var selectedIndexPath: IndexPath?
    let viewModel: FeeRateViewModel
    
    init(transaction: FBTransaction) {
        self.viewModel = FeeRateViewModel(transaction: transaction)
        super.init(nibName: "FeeRateViewController", bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = FeeRateViewModel()
        super.init(coder: aDecoder)
    }
    
    #if EW
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager) {
        viewModel.setup(loadingManager: loadingManager, coordinator: coordinator, ewManager: ewManager)
    }
    #else
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator) {
        viewModel.loadingManager = loadingManager
        viewModel.coordinator = coordinator
    }
    #endif

    //MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configButtons()
        viewModel.fetchFeeRates()
    }
    
    private func configButtons(){
        createTransactionButton.config(title: "Create transaction", style: .Primary)
        createTransactionButton.isEnabled = viewModel.isContinueButtonEnabled()
    }
    
    @IBAction func createTransactionTapped(_ sender: AppActionBotton) {
        showActivityIndicator(message: LocalizableStrings.feeActivityIndicatorMessage)
        viewModel.createTransaction()
    }
    
    private func navigateToApproveScreen(){
        if let transaction = viewModel.getTransaction() {
            viewModel.coordinator?.path.append(NavigationTypes.approveTransaction(transaction))
        }
    }    
}

//MARK: - UITableViewDataSource
extension FeeRateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getFeesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeeRateCell.nibName, for: indexPath) as? FeeRateCell  else {
            return UITableViewCell()
        }
        
        let fee = viewModel.getFees()[indexPath.row]
        let assetName = viewModel.transaction.asset.asset?.symbol ?? ""
        cell.configCell(with: fee, assetName: assetName)
        let selectedFeeIndex = viewModel.getSelectedIndex()
        
        if indexPath.row == selectedFeeIndex {
            selectedIndexPath = indexPath
            cell.setSelected(isSelected: true)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FeeRateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FeeRateCell {
            cell.setSelected(isSelected: true)
        }
        
        if let selectedIndexPath = selectedIndexPath, let previousCell = tableView.cellForRow(at: selectedIndexPath) as? FeeRateCell {
            previousCell.setSelected(isSelected: false)
        }
        
        viewModel.selectFee(at: indexPath.row)
        selectedIndexPath = indexPath
        self.createTransactionButton.isEnabled = self.viewModel.isContinueButtonEnabled()
    }
}

extension FeeRateViewController: FeeRateViewModelDelegate {
    func isTransactionCreated(isCreated: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideActivityIndicator()
            if isCreated {
                self.navigateToApproveScreen()
            } else {
                self.createTransactionButton.isEnabled = false
            }
        }
    }
    
    func refreshData() {
        DispatchQueue.main.async { [weak self] in
            if let self {
                self.tableView.reloadData()
                self.createTransactionButton.isEnabled = self.viewModel.isContinueButtonEnabled()
            }
        }
    }
}
