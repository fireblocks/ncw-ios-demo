//
//  EWNFTPreviewViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev
import Combine

extension EWNFTPreviewView {
    @Observable
    class ViewModel {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var dataModel: NFTDataModel
        private var pollingManagerTxId: PollingManagerTxId!
        private var cancellable = Set<AnyCancellable>()
        private var didLoad = false
        
        init(dataModel: NFTDataModel) {
            self.dataModel = dataModel
        }

        deinit {
            cancellable.removeAll()
            print("DEINIT EWNFTPreviewViewModel")
        }

        func setup(loadingManager: LoadingManager, ewManager: EWManager, coordinator: Coordinator) {
            if !didLoad {
                self.loadingManager = loadingManager
                self.ewManager = ewManager
                self.coordinator = coordinator
                self.pollingManagerTxId = PollingManagerTxId(ewManager: ewManager)
                listenToTransferChanges()
                if let txId = dataModel.transaction?.id {
                    Task {
                        await pollingManagerTxId?.startPolling(txId: txId)
                    }
                }

            }
        }
        
        func cancelTransaction() {
            
        }

        private func listenToTransferChanges() {
            pollingManagerTxId?.$response.receive(on: RunLoop.main)
                .sink { [weak self] response in
                    if let self, let response {
                        if let transactionID = self.dataModel.transaction?.id, transactionID == response.id {
                            self.dataModel.transaction?.status = response.status
                        }
                    }
                }.store(in: &cancellable)
        }

    }
}
