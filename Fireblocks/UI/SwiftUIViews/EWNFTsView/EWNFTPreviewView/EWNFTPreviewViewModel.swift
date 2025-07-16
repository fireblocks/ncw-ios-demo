//
//  EWNFTPreviewViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
import Combine
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

extension EWNFTPreviewView {
    @Observable
    class ViewModel {
        var coordinator: Coordinator?
        var loadingManager: LoadingManager?
        var ewManager: EWManager?
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
                    pollingManagerTxId?.startPolling(txId: txId)
                }
            }
        }
        
        func approveTransaction() {
            guard let ewManager else { return }
            if let transactionID = self.dataModel.transaction?.id {
                self.loadingManager?.isLoading = true
                Task {
                    do {
                        let result = try await ewManager.getCore().signTransaction(txId: transactionID)
                        if result.transactionSignatureStatus == .ERROR || result.transactionSignatureStatus == .TIMEOUT {
                            let error = FireblocksManager.shared.getError(.transaction, defaultError: CustomError.approveTransaction)
                            await self.loadingManager?.setAlertMessage(error: error)
                        } else {
                            await MainActor.run {
                                self.coordinator?.path = NavigationPath()
                                self.loadingManager?.isLoading = false
                            }
                        }
                    } catch {
                        await self.loadingManager?.setAlertMessage(error: error)
                    }
                }
            }
        }
        
        func cancelTransaction() {
            guard let ewManager else { return }
            if let transactionID = self.dataModel.transaction?.id {
                self.loadingManager?.isLoading = true
                Task {
                    do {
                        let result = try await ewManager.cancelTransaction(txId: transactionID)
                        if let success = result.success, success {
                            await MainActor.run {
                                self.coordinator?.path = NavigationPath()
                            }
                        } else {
                            let error = FireblocksManager.shared.getError(.transaction, defaultError: CustomError.cancelTransaction)
                            await self.loadingManager?.setAlertMessage(error: error)
                        }
                        await self.loadingManager?.setLoading(value: false)

                    } catch {
                        await self.loadingManager?.setAlertMessage(error: error)
                    }
                }
            }
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
