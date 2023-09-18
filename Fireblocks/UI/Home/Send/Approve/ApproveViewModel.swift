//
//  ApproveViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation

protocol ApproveViewModelDelegate: AnyObject {
    func transactionStatusChanged(isApproved: Bool)
    func cancelTransactionStatusChanged(isCanceled: Bool)
}

final class ApproveViewModel {
    var transaction: Transaction!
    let repository = ApproveRepository()
    weak var delegate: ApproveViewModelDelegate?
    
    func getTransaction() -> Transaction {
        return transaction
    }
    
    func getAmount() -> String {
        return "\(transaction.amountToSend) \(transaction.asset.symbol)"
    }
    
    func getAmountPrice() -> String {
        return "$\(transaction.price)"
    }
    
    func getReceiverAddress() -> String {
        return transaction.receiverAddress ?? ""
    }
    func getFeeAmount() -> String {
        guard let fee = transaction.fee?.fee else { return "" }
        return "\(fee) \(transaction.asset.symbol)"
    }
    
    func getTotalAmount() -> String {
        if let fee = transaction.getFee() {
            let totalAmount = transaction.amountToSend + fee
            return "\(totalAmount) \(transaction.asset.symbol)"
        }
        
        return ""
    }
    
    func getTotalAmountPrice() -> String {
        if let fee = transaction.getFee(), let rate = transaction.asset.rate {
            let totalAmount = transaction.amountToSend + fee
            let totalPrice = totalAmount * rate
            
            return "$\(totalPrice.formatFractions(fractionDigits: 2))"
        }
        
        return ""
    }
    
    func approveTransaction() {
        guard let transactionId = transaction.txId else { return }
        Task {
            let isApproved = await repository.approveTransaction(transactionId: transactionId)
            self.delegate?.transactionStatusChanged(isApproved: isApproved)
            
        }
    }
    
    func cancelTransaction() {
        guard let transactionId = transaction.txId else { return }
        let assetId = transaction.asset.id
        Task {
            do {
                let isCanceled = try await repository.cancelTransaction(assetId: assetId, txId: transactionId)
                delegate?.cancelTransactionStatusChanged(isCanceled: isCanceled)
            } catch {
                print("error")
            }
            
        }
    }
}
