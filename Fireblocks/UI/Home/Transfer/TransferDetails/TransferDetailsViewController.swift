//
//  TransferDetailsViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 09/07/2023.
//

import UIKit

class TransferDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var operationTitle: UILabel!
    @IBOutlet weak var assetBlockchainBackground: UIView!
    
    @IBOutlet weak var assetBlockchain: UILabel!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var statusBackground: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var creationDate: UILabel!
    @IBOutlet weak var receiverAddressTitle: UILabel!
    @IBOutlet weak var receiverAddress: UILabel!
    @IBOutlet weak var copyAddress: UIButton!
    @IBOutlet weak var fee: UILabel!
    @IBOutlet weak var transactionHash: UILabel!
    @IBOutlet weak var copyTransactionHashButton: UIButton!
    @IBOutlet weak var fireblocksId: UILabel!
    @IBOutlet weak var copyFireblocksIdButton: UIButton!
    @IBOutlet weak var approveButton: AppActionBotton!
    
    let viewModel: TransferDetailsViewModel
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(withTransfer transferInfo: TransferInfo?) {
        self.viewModel = TransferDetailsViewModel(transferInfo: transferInfo )
        super.init (nibName: "TransferDetailsViewController", bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        copyAddress.setTitle("", for: .normal)
        copyFireblocksIdButton.setTitle("", for: .normal)
        copyTransactionHashButton.setTitle("", for: .normal)
        configView()
        configButtons()
        viewModel.setDelegate(delegate: self)

    }
    
    private func configView(){
        self.navigationItem.titleView = titleView
        
        assetBlockchainBackground.layer.cornerRadius = assetBlockchainBackground.frame.height / 2
        statusBackground.layer.cornerRadius = 6
        
        if let transfer = viewModel.transferInfo {
            assetImage.image = transfer.image
            operationTitle.text = transfer.getTransferTitle(walletId: FireblocksManager.shared.getWalletId())
            assetBlockchain.text = transfer.blockChainName
            amount.text = "\(transfer.amount) \(transfer.assetSymbol)"
            price.text = "$\(transfer.price)"
            statusLabel.text = transfer.status.rawValue
            statusLabel.textColor = transfer.status.color
            statusBackground.addBorder(color: transfer.status.color, width: 0.5)
            creationDate.text = transfer.creationDate
            receiverAddressTitle.text = transfer.getReceiverTitle(walletId: FireblocksManager.shared.getWalletId())
            receiverAddress.text = transfer.getReceiverAddress(walletId: FireblocksManager.shared.getWalletId())
            fee.text = "\(transfer.fee.formatFractions(fractionDigits: 6))"
            transactionHash.text = transfer.getTxHash()
            fireblocksId.text = transfer.transactionID
        }
    }
    
    private func configButtons(){
//        let testCancel = true
//        if testCancel {
//            navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCancelTap))]
//        }
        approveButton.isHidden = !viewModel.isPending
        let buttonImage = AssetsIcons.checkMark.getIcon()
        approveButton.config(title: "Approve", image: buttonImage, style: .Primary)
        
    }
    
    @objc func handleCancelTap() {
        showActivityIndicator()
        viewModel.cancelTransaction()
    }
    
    @IBAction func approveTapped(_ sender: AppActionBotton) {
        showActivityIndicator()
        viewModel.approveTransaction()
    }
    
    private func showAlertView(message: String){
        showAlert(description: message, bottomAnchor: approveButton.topAnchor)
    }

    private func navigateToTransactionSent(){
        if let transaction = viewModel.transferInfo?.toTransaction() {
            let vc = TransactionSentViewController(nibName: "TransactionSentViewController", bundle: nil)
            vc.viewModel.transaction = transaction
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showAlertView(message: LocalizableStrings.approveTxFailed)
        }
    }

    @IBAction func copyAddressTapped(_ sender: UIButton) {
        guard let labelText = receiverAddress.text else {
            showToast("Copy failed", type: .failed)
            return
        }
        
        UIPasteboard.general.string = labelText
        showToast()
    }
    

    @IBAction func copyTransactionHashTapped(_ sender: UIButton) {
        
        guard let isTxHashEmpty = viewModel.transferInfo?.isTxHashEmpty() else {
            showToast("Copy failed", type: .failed)
            return
        }
        
        if !isTxHashEmpty {
            guard let labelText = transactionHash.text else {
                showToast("Copy failed", type: .failed)
                return
            }
            
            UIPasteboard.general.string = labelText
            showToast()
        } else {
            showToast("Copy failed", type: .failed)
        }
    }
    
    @IBAction func copyFireblocksIdTapped(_ sender: UIButton) {
        guard let labelText = fireblocksId.text else {
            showToast("Copy failed", type: .failed)
            return
        }
        
        UIPasteboard.general.string = labelText
        showToast()
    }
    
    @objc func handleBackTap(_ gesture: UITapGestureRecognizer) {
        tabBarController?.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
    }
}

extension TransferDetailsViewController: TransferDetailsViewModelDelegate {
    func transferDidUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.configView()
            self?.configButtons()
        }
    }
    
    func transactionStatusChanged(isApproved: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.hideActivityIndicator()
            if isApproved{
                self?.navigateToTransactionSent()
            } else {
                self?.showAlertView(message: LocalizableStrings.approveTxFailed)
            }
        }
    }

    func transactionCancelStatusChanged(isCanceled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.hideActivityIndicator()
            if isCanceled {
                self?.navigationController?.popToRootViewController(animated: true)
            } else {
                self?.showAlertView(message: LocalizableStrings.approveTxFailed)
            }
        }
    }



}
