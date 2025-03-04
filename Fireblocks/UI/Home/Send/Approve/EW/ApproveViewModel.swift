//
//  Untitled.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 03/03/2025.
//

import Foundation
import Combine

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

@Observable
class ApproveViewModel: ApproveViewModelBase {
    var ewManager: EWManager?
    var pollingManagerTxId: PollingManagerTxId?

    weak var transferDelegate: TransferDetailsViewModelDelegate?
    
    func setup(coordinator: Coordinator,
               loadingManager: LoadingManager,
               ewManager: EWManager, fireblocksManager: FireblocksManager) {
        if !didLoad {
            self.didLoad = true
            self.coordinator = coordinator
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.repository = ApproveRepository(ewManager: ewManager, fireBlocksManager: fireblocksManager)
            self.pollingManagerTxId = PollingManagerTxId(ewManager: ewManager)
            if let txId = transaction.txId {
                self.pollingManagerTxId?.startPolling(txId: txId)
                self.listenToTransferChanges(txId: txId)
            }
        }
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

    
    override func getTotalAmountPrice() -> String {
        var totalAmount = transaction.amountToSend
        if let fee = transaction.getFee() {
            totalAmount += fee
        }
        
        if let assetId = transaction.asset.asset?.id {
            return CryptoCurrencyManager.shared.getTotalPrice(assetId: assetId, amount: totalAmount)
        }
        
        return "$\(totalAmount.formatFractions(fractionDigits: 2))"

//        if let fee = transaction.getFee(), let rate = transaction.asset.asset?.rate {
//            let totalAmount = transaction.amountToSend + fee
//            let totalPrice = totalAmount * rate
//            
//            return "$\(totalPrice.formatFractions(fractionDigits: 2))"
//        }
//        return "$\(transaction.amountToSend.formatFractions(fractionDigits: 2))"
    }
        
    
}
