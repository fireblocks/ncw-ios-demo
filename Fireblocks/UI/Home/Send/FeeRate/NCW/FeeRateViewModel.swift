//
//  FeeRateViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation
import Combine

final class FeeRateViewModel: FeeRateViewModelBase {
    func setup(loadingManager: LoadingManager, coordinator: Coordinator) {
        if !didLoad {
            didLoad = true
            self.loadingManager = loadingManager
            self.coordinator = coordinator
            self.repository = FeeRateRepository()
            fetchFeeRates()
        }

    }
        
    @MainActor
    override func listenToTransactionStatusChanges() {
        if let transactionID = self.transactionID {
            let failedStatus: [Status] = [.failed, .blocked, .cancelled, .rejected]
            TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
                .sink { [weak self] (transfers: [TransferInfo]) in
                    if let self {
                        if let transferInfo = transfers.first(where: {$0.transactionID == transactionID}) {
                            if let transaction = transferInfo.toTransaction(assetListViewModel: AssetListViewModel.shared) {
                                self.loadingManager?.isLoading = false
                                self.coordinator?.path.append(NavigationTypes.approveTransaction(transaction, true))
                            } else {
                                self.loadingManager?.isLoading = false
                                self.loadingManager?.setAlertMessage(error: CustomError.genericError("Failed to get transaction"))
                            }
                        }
                    }
                }.store(in: &cancellable)
        }
    }
    
}
