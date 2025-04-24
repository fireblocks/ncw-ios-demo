//
//  TransfersViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//

import Combine

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

final class TransfersViewModel: TransfersViewModelBase {
    static let shared = TransfersViewModel()

    override init() {
        super.init()
        listenToTransferChanges()
    }

    private let pollingManager = PollingManager.shared
    private var ewMAnager: EWManager?
    
    func setup(ewManager: EWManager) {
        self.ewMAnager = ewManager
    }
        
    func listenToTransferChanges() {
        pollingManager.$transactions.receive(on: RunLoop.main)
            .sink { [weak self] transactions in
                if let self {
                    DispatchQueue.main.async {
                        self.handleTransactions(transactions: transactions)
                    }
                }
            }.store(in: &cancellable)
    }
    
}
