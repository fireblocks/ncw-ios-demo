//
//  ApproveViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import UIKit

class ApproveViewController: UIViewController {
    
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var amountPrice: UILabel!
    @IBOutlet weak var receiverAddressBackground: UIView!
    @IBOutlet weak var receiverAddress: UILabel!
    @IBOutlet weak var feeAmount: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var approveButton: AppActionBotton!
    @IBOutlet weak var stopButton: AppActionBotton!

    let viewModel = ApproveViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configView()
        configButtons()
    }
    
    private func configView(){
        receiverAddressBackground.layer.cornerRadius = 4
        
        amount.text = viewModel.getAmount()
        amountPrice.text = viewModel.getAmountPrice()
        receiverAddress.text = viewModel.getReceiverAddress()
        feeAmount.text = viewModel.getFeeAmount()
        
        totalAmount.text = viewModel.getTotalAmount()
        totalPrice.text = viewModel.getTotalAmountPrice()
    }
    
    private func configButtons(){
        self.showToolbar(show: true)
        self.navigationItem.title = "Preview"
        self.navigationItem.hidesBackButton = true
        let buttonImage = AssetsIcons.checkMark.getIcon()
        approveButton.config(title: "Approve", image: buttonImage, style: .Primary)
        stopButton.config(title: "Stop", image: buttonImage, style: .Secondary)

    }
    
    @objc private func handleCloseTap() {
        showBottomSheet()
    }
    
    private func showBottomSheet(){
        let vc = AreYouSureBottomSheet.Builder()
            .setIcon(AssetsIcons.cancelTransaction)
            .setConfirmButtonTitle("Discard transaction")
            .setUserActionDelegate(self)
            .build()
        navigationController?.present(vc, animated: true)
    }
    
    @IBAction func approveTapped(_ sender: AppActionBotton) {
        self.showToolbar(show: false)
        viewModel.approveTransaction()
    }
    
    @IBAction func stoppedTapped(_ sender: AppActionBotton) {
        viewModel.stopTransaction()
    }

    
    private func navigateHome(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func showAlertView(message: String){
        showAlert(description: message, bottomAnchor: approveButton.topAnchor)
    }
    
    private func navigateToTransactionSent(){
        let vc = TransactionSentViewController(nibName: "TransactionSentViewController", bundle: nil)
        vc.viewModel.transaction = viewModel.getTransaction()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UserActionDelegate
extension ApproveViewController: UserActionDelegate {
    func confirmButtonClicked() {
        self.showToolbar(show: false)
        viewModel.cancelTransaction()
        showActivityIndicator()
    }
}

//MARK: - ApproveViewModelDelegate
extension ApproveViewController: ApproveViewModelDelegate {
    func transactionStatusChanged(isApproved: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let self {
                self.hideActivityIndicator()
                if isApproved{
                    self.navigateToTransactionSent()
                } else {
                    self.showToolbar(show: true)
                    self.showAlertView(message: LocalizableStrings.approveTxFailed)
                }
            }
        }
    }
    
    func cancelTransactionStatusChanged(isCanceled: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let self {
                self.hideActivityIndicator()
                if isCanceled {
                    self.navigateHome()
                } else {
                    self.showToolbar(show: true)
                    self.showAlertView(message: LocalizableStrings.cancelTxFailed)
                }
            }
        }
    }
    
    private func showToolbar(show: Bool) {
        if show {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(goHome))]
        } else {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.leftBarButtonItems = nil
        }
    }
    
    func hideIndicator() {
        self.hideActivityIndicator()
    }
    
    @objc func goHome() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
