//
//  FeeRateViewModel.swift
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
final class FeeRateViewModel: FeeRateViewModelBase {
    var ewManager: EWManager?
    var pollingManagerTxId: PollingManagerTxId?

    func setup(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager) {
        if !didLoad {
            didLoad = true
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
            self.repository = FeeRateRepository(ewManager: ewManager)
            self.pollingManagerTxId = PollingManagerTxId(ewManager: ewManager)
            fetchFeeRates()
        }

    }
    
    override func listenToTransactionStatusChanges() {
        if let transactionID = self.transactionID {
            pollingManagerTxId?.startPolling(txId: transactionID)
            pollingManagerTxId?.$response.receive(on: RunLoop.main)
                .sink { [weak self] response in
                    if let self, let response {
                        if transactionID == response.id {
                            self.loadingManager?.isLoading = false
                            self.coordinator?.path.append(NavigationTypes.approveTransaction(transaction, true))
                            self.pollingManagerTxId?.stopPolling()
                        }
                    }
                }.store(in: &cancellable)

        }
    }
    
}
