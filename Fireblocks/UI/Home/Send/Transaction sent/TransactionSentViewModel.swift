//
//  TransactionSentViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import Foundation

protocol TransactionSentViewModelDelegate: AnyObject {
    func navigateToNextScreen(with transferInfo: TransferInfo)
    func showError(message: String)
}

final class TransactionSentViewModel {
    
//MARK: - PROPERTIES
    var transaction: FBTransaction!
    private var transfersInfo: [TransferInfo] = []
    weak var delegate: TransactionSentViewModelDelegate?
    
//MARK: - FUNCTIONS
    func getAmount() -> String {
        return "\(transaction.amountToSend) \(transaction.asset.symbol)"
    }
    
    func getAmountPrice() -> String {
        return "$\(transaction.price)"
    }
    
    func getReceiverAddress() -> String {
        return transaction.receiverAddress ?? ""
    }
    
    func getTitle() -> String {
        return "Sending \(transaction.asset.symbol)"
    }
    
    func fetchTransfers() {
        getCurrentTransactionInfo()
    }
    
    func getCurrentTransactionInfo() {
        if let index = TransfersViewModel.shared.transfers.firstIndex(where: {$0.transactionID == transaction.txId}) {
            TransfersViewModel.shared.updateStatusWhenApproved(index: index)
            delegate?.navigateToNextScreen(with: TransfersViewModel.shared.transfers[index])

        } else {
            delegate?.showError(message: LocalizableStrings.failedToGetTransactionInfo)
        }
    }
}

