//
//  ApproveViewModelBase.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 04/03/2025.
//

import SwiftUI
import Combine
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

@Observable
class ApproveViewModelBase {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    var transaction: FBTransaction
    var repository: ApproveRepository?
    
    var transferInfo: TransferInfo?
    var cancellable = Set<AnyCancellable>()
    var isTransferring = false
    
    var didLoad = false
    var isDiscardAlertPresented = false
    let fromCreate: Bool
    init(transaction: FBTransaction = FBTransaction(), fromCreate: Bool) {
        self.transaction = transaction
        self.fromCreate = fromCreate
    }
    
    deinit {
        print("ApproveViewModelBase deinit")
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
            let fee = transferInfo.fee.formatFractionsAsString(fractionDigits: 6)
            let symbol = AssetsUtils.removeTestSuffix(transferInfo.assetSymbol)
            return "\(fee) \(symbol)"
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
        fatalError("getTotalAmountPrice should be implemented on child class")
    }
    
    func approveTransaction() {
        guard let repository, let transactionId = transaction.txId else {
            self.loadingManager?.isLoading = false
            return
        }
        self.loadingManager?.isLoading = true

        Task {
            do {
                let isApproved = try await repository.approveTransaction(transactionId: transactionId)
                await self.loadingManager?.setLoading(value: false)

                if isApproved {
                    await MainActor.run {
                        withAnimation {
                            isTransferring = true
                        }
                    }
                } else {
                    await MainActor.run {
                        self.isTransferring = false
                    }
                    await self.loadingManager?.setAlertMessage(error: CustomError.genericError("Failed to approve transaction"))
                }
            } catch {
                await MainActor.run {
                    self.isTransferring = false
                }
                await self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }

    func stopTransaction() {
        try? repository?.stopTransaction()
    }

    func cancelTransaction() {
        guard let repository, let transactionId = transaction.txId else {
            self.loadingManager?.isLoading = false
            return
        }
        let assetId = transaction.asset.id
        self.loadingManager?.isLoading = true
        Task {
            do {
                let isCanceled = try await repository.cancelTransaction(assetId: assetId, txId: transactionId)
                await self.loadingManager?.setLoading(value: false)
                if isCanceled {
                    await MainActor.run {
                        self.coordinator?.path = NavigationPath()
                    }
                } else {
                    await self.loadingManager?.setAlertMessage(error: CustomError.genericError("Failed to cancel transaction"))
                }
            } catch {
                await self.loadingManager?.setAlertMessage(error: error)
            }
            
        }
    }
}
