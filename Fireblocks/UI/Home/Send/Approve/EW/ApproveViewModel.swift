//
//  Untitled.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 03/03/2025.
//

import Foundation
import Combine

@Observable
final class ApproveViewModel {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    var ewManager: EWManager?
    var pollingManagerTxId: PollingManagerTxId?

    var transaction: FBTransaction
    var repository: ApproveRepository?
    weak var delegate: ApproveViewModelDelegate?
    
    var transferInfo: TransferInfo?
    weak var transferDelegate: TransferDetailsViewModelDelegate?
    private var cancellable = Set<AnyCancellable>()
    var didLoad = false
    init(transaction: FBTransaction = FBTransaction()) {
        self.transaction = transaction
    }
    
    func setup(coordinator: Coordinator,
               loadingManager: LoadingManager,
               ewManager: EWManager) {
        if !didLoad {
            self.didLoad = true
            self.coordinator = coordinator
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.repository = ApproveRepository(ewManager: ewManager, fireBlocksManager: FireblocksManager.shared)
            self.pollingManagerTxId = PollingManagerTxId(ewManager: ewManager)
            if let txId = transaction.txId {
                self.pollingManagerTxId?.startPolling(txId: txId)
                self.listenToTransferChanges(txId: txId)
            }
        }
    }

    func setDelegate(delegate: TransferDetailsViewModelDelegate?) {
        self.transferDelegate = delegate
//        listenToTransferChanges()
    }

    private func listenToTransferChanges(txId: String) {
        pollingManagerTxId?.$response.receive(on: RunLoop.main)
            .sink { [weak self] response in
                if let self, let response {
                    if txId == response.id {
                        self.transferInfo = TransferInfo.toTransferInfo(response: response)
                    }
                }
            }.store(in: &cancellable)
    }

    func getCreationDate() -> String {
        return transferInfo?.creationDate ?? ""
    }

    func getReceivedFrom() -> String {
        return transferInfo?.getReceiverAddress(walletId: FireblocksManager.shared.getWalletId()) ?? ""
    }
    
    func getReceivedFromTitle() -> String {
        return transferInfo?.getReceiverTitle(walletId: FireblocksManager.shared.getWalletId()) ?? ""
    }


    func getFee() -> String {
        if let transferInfo {
            return "\(transferInfo.fee) \(transferInfo.assetId)"
        }
        return "0"
    }
    
    func getTransactionHash() -> String {
        if let transferInfo {
            return transferInfo.getTxHash()
        }
        return ""
    }

    func getTransactionId() -> String {
        if let transferInfo {
            return transferInfo.transactionID
        }
        return ""
    }
    
    func getAssetId() -> String {
        if let transferInfo {
            return transferInfo.assetId
        }
        return ""
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
        #if EW
        var totalAmount = transaction.amountToSend
        if let fee = transaction.getFee() {
            totalAmount += fee
        }
        
        if let assetId = transaction.asset.asset?.id {
            return CryptoCurrencyManager.shared.getTotalPrice(assetId: assetId, amount: totalAmount)
        }
        
        return "$\(totalAmount.formatFractions(fractionDigits: 2))"

        #else
        if let fee = transaction.getFee(), let rate = transaction.asset.asset?.rate {
            let totalAmount = transaction.amountToSend + fee
            let totalPrice = totalAmount * rate
            
            return "$\(totalPrice.formatFractions(fractionDigits: 2))"
        }
        return "$\(transaction.amountToSend.formatFractions(fractionDigits: 2))"

        #endif
    }
    
    func approveTransaction() {
        guard let repository, let transactionId = transaction.txId else {
            delegate?.hideIndicator()
            return
        }
        Task {
            let isApproved = await repository.approveTransaction(transactionId: transactionId)
            self.delegate?.transactionStatusChanged(isApproved: isApproved)
            
        }
    }
    
    func stopTransaction() {
        repository?.stopTransaction()
    }
    
    func cancelTransaction() {
        guard let repository, let transactionId = transaction.txId else {
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
