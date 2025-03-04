//
//  TransferDetailsViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
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

class TransferDetailsViewModel {
    var ewManager: EWManager = EWManager.shared
    var pollingManagerTxId = PollingManagerTxId(ewManager: EWManager.shared)
    var didLoad = false
    
    var transferInfo: TransferInfo?
    var hideBackBarButton: Bool
    private var cancellable = Set<AnyCancellable>()

    weak var delegate: TransferDetailsViewModelDelegate?

    init(transferInfo: TransferInfo?, hideBackBarButton: Bool) {
        self.transferInfo = transferInfo
        self.hideBackBarButton = hideBackBarButton
    }
    
    deinit {
        cancellable.removeAll()
        print("DEINIT TransactionViewModel")
    }

    func setDelegate(delegate: TransferDetailsViewModelDelegate?) {
        self.delegate = delegate
        guard let txId = transferInfo?.transactionID else {
            return
        }
        listenToTransferChanges()

        Task {
            await self.pollingManagerTxId.startPolling(txId: txId)
        }

    }
    
    private func listenToTransferChanges() {
        pollingManagerTxId.$response.receive(on: RunLoop.main)
            .sink { [weak self] response in
                if let self, let response {
                    if let transactionID = self.transferInfo?.transactionID, transactionID == response.id {
                        self.transferInfo = TransferInfo.toTransferInfo(response: response)
                        self.delegate?.transferDidUpdate()
                    }
                }
            }.store(in: &cancellable)
    }


    var isPending: Bool {
        return transferInfo?.status == .pendingSignature
    }
    
    var isCompleted: Bool {
        return transferInfo?.status == .completed
    }

    func reload() async {
        guard let txId = transferInfo?.transactionID else {
            return
        }
        await self.pollingManagerTxId.pollTransaction(txId: txId, poll: false)
    }
    
    func isApproveDisabled() -> Bool {
        guard let txId = transferInfo?.transactionID else {
            return true
        }
        
        guard let approvedTransactions = UsersLocalStorageManager.shared.approvedTransactions.value() else {
            return true
        }
        
        if transferInfo?.status != .pendingSignature {
            return true
        }
        
        if approvedTransactions.contains(txId) {
            return true
        }
        
        return false
    }
    
    func approveTransaction() async  {
        if let txId = transferInfo?.transactionID {
            if await FireblocksManager.shared.signTransaction(transactionId: txId) {
                var approvedTransactions = UsersLocalStorageManager.shared.approvedTransactions.value() ?? []
                approvedTransactions.append(txId)
                UsersLocalStorageManager.shared.approvedTransactions.set(approvedTransactions)
            }
        }
    }
    
    func cancelTransaction() async {
        guard let txId = transferInfo?.transactionID else {
            ewManager.errorMessage = "Unknown Transaction ID"
            self.delegate?.transactionCancelStatusChanged(isCanceled: false)
            return
        }

        let isCanceled = try? await self.ewManager.cancelTransaction(txId: txId).success == true
        self.delegate?.transactionCancelStatusChanged(isCanceled: isCanceled ?? false)

    }

}
