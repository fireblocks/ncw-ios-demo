//
//  ApproveViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation
import Combine

protocol ApproveViewModelDelegate: AnyObject {
    func transactionStatusChanged(isApproved: Bool)
    func cancelTransactionStatusChanged(isCanceled: Bool)
    func hideIndicator()
}

final class ApproveViewModel {
    var transaction: FBTransaction!
    let repository = ApproveRepository()
    weak var delegate: ApproveViewModelDelegate?
    
    var transferInfo: TransferInfo?
    weak var transferDelegate: TransferDetailsViewModelDelegate?
    private var cancellable = Set<AnyCancellable>()

    func setDelegate(delegate: TransferDetailsViewModelDelegate?) {
        self.transferDelegate = delegate
        listenToTransferChanges()
    }

    private func listenToTransferChanges() {
        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
            .sink { [weak self] transfers in
                if let self {
                    if let transactionInfo = transfers.first(where: {$0.transactionID == self.transaction.txId}) {
                        self.transferInfo = transactionInfo
                        self.transferDelegate?.transferDidUpdate()
                    }
                }
            }.store(in: &cancellable)
    }

    func getTransaction() -> FBTransaction {
        return transaction
    }
    
    func getAmount() -> String {
        return "\(transaction.amountToSend) \(transaction.asset.asset?.symbol ?? "")"
    }
    
    func getAmountPrice() -> String {
        return "$\(transaction.price)"
    }
    
    func getReceiverAddress() -> String {
        return transaction.receiverAddress ?? ""
    }
    func getFeeAmount() -> String {
        guard let fee = transaction.fee?.fee else { return "" }
        return "\(fee) \(transaction.asset.asset?.symbol ?? "")"
    }
    
    func getTotalAmount() -> String {
        if let fee = transaction.getFee() {
            let totalAmount = transaction.amountToSend + fee
            return "\(totalAmount) \(transaction.asset.asset?.symbol ?? "")"
        }
        
        return ""
    }
    
    func getTotalAmountPrice() -> String {
        //TODO - get rate EW
        #if EW
        #else
        if let fee = transaction.getFee(), let rate = transaction.asset.asset?.rate {
            let totalAmount = transaction.amountToSend + fee
            let totalPrice = totalAmount * rate
            
            return "$\(totalPrice.formatFractions(fractionDigits: 2))"
        }
        #endif
        
        return ""
    }
    
    func approveTransaction() {
        guard let transactionId = transaction.txId else {
            delegate?.hideIndicator()
            return
        }
        Task {
            let isApproved = await repository.approveTransaction(transactionId: transactionId)
            self.delegate?.transactionStatusChanged(isApproved: isApproved)
            
        }
    }
    
    func stopTransaction() {
        repository.stopTransaction()
    }
    
    func cancelTransaction() {
        guard let transactionId = transaction.txId else {
            delegate?.hideIndicator()
            return
        }
        let assetId = transaction.asset.id
        Task {
            do {
                let isCanceled = try await repository.cancelTransaction(assetId: assetId, txId: transactionId)
                delegate?.cancelTransactionStatusChanged(isCanceled: isCanceled)
            } catch {
                delegate?.cancelTransactionStatusChanged(isCanceled: false)
            }
            
        }
    }
}
