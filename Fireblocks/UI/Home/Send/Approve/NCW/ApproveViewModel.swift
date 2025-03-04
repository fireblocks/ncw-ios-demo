//
//  ApproveViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation
import Combine


@Observable
class ApproveViewModel: ApproveViewModelBase {
    func setup(coordinator: Coordinator,
               loadingManager: LoadingManager,
               fireblocksManager: FireblocksManager) {
        if !didLoad {
            self.didLoad = true
            self.coordinator = coordinator
            self.loadingManager = loadingManager
            self.repository = ApproveRepository(fireblocksManager: fireblocksManager)
            if let txId = transaction.txId {
                self.listenToTransferChanges(txId: txId)
            }
        }
    }

    private func listenToTransferChanges(txId: String) {
        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
            .sink { [weak self] transfers in
                if let self {
                    if let transactionInfo = transfers.first(where: {$0.transactionID == self.transaction.txId}) {
                        self.transferInfo = transactionInfo
                    }
                }
            }.store(in: &cancellable)
    }

    
    override func getTotalAmountPrice() -> String {
        if let fee = transaction.getFee(), let rate = transaction.asset.asset?.rate {
            let totalAmount = transaction.amountToSend + fee
            let totalPrice = totalAmount * rate

            return "$\(totalPrice.formatFractions(fractionDigits: 2))"
        }
        return "$\(transaction.amountToSend.formatFractions(fractionDigits: 2))"
    }
        
    
}
