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
    deinit {
        print("ApproveViewModel deinit")
    }
    
    @MainActor
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

    @MainActor
    private func updateTransaction(txId: String) {
        if let transactionInfo = TransfersViewModel.shared.transfers.first(where: {$0.transactionID == txId}) {
            self.transferInfo = transactionInfo
        }
    }
    
    @MainActor
    private func listenToTransferChanges(txId: String) {
//        withObservationTracking {
//            updateTransaction(txId: txId)
//        } onChange: {
//            DispatchQueue.main.async {
//                self.listenToTransferChanges(txId: txId)
//            }
//        }

        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
            .sink { [weak self] transfers in
                if let self {
                    if let transactionInfo = transfers.first(where: {$0.transactionID == self.transaction.txId}) {
                        self.transferInfo = transactionInfo
                        if isTransferring, let transferInfo, transferInfo.isEndedTransaction() {
                            self.isTransferring = false
                        }
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
