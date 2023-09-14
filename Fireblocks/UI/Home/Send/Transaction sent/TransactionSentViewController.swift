//
//  TransactionSentViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import UIKit

class TransactionSentViewController: UIViewController {

//MARK: - PROPERTIES 
    @IBOutlet weak var imageResult: UIImageView!
    @IBOutlet weak var sendTitle: UILabel!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var assetAmount: UILabel!
    @IBOutlet weak var amountPrice: UILabel!
    @IBOutlet weak var addressBackground: UIView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var showTransactionButton: AppActionBotton!
 
    let viewModel = TransactionSentViewModel()
    
//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configView()
        configButtons()
    }
    
//MARK: - FUNCTIONS
    private func configView(){
        addressBackground.layer.cornerRadius = 4
        
        assetImage.image = viewModel.transaction.asset.image
        sendTitle.text = viewModel.getTitle()
        assetAmount.text = viewModel.getAmount()
        amountPrice.text = viewModel.getAmountPrice()
        address.text = viewModel.getReceiverAddress()
        
    }
    
    private func configButtons(){
        showTransactionButton.config(title: "Show transaction", style: .Primary)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
    }
    
    @objc private func handleCloseTap() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func showTransactionTapped(_ sender: AppActionBotton) {
        self.showActivityIndicator()
        viewModel.fetchTransfers()
    }
    
    private func showAlertView(message: String){
        showAlert(description: message, bottomAnchor: showTransactionButton.topAnchor)
    }
}

//MARK: - TransactionSentViewModelDelegate
extension TransactionSentViewController: TransactionSentViewModelDelegate {
    func navigateToNextScreen(with transferInfo: TransferInfo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.hideActivityIndicator()
            let vc = TransferDetailsViewController(withTransfer: transferInfo)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.showAlertView(message: message)
            self.hideActivityIndicator()
        }
    }
}
