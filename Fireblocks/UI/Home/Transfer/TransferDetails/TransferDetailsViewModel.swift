//
//  TransferDetailsViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/07/2023.
//

import Foundation
import Combine

protocol TransferDetailsViewModelDelegate: AnyObject {
    func transferDidUpdate()
    func transactionStatusChanged(isApproved: Bool)
    func transactionCancelStatusChanged(isCanceled: Bool)
}

class TransferDetailsViewModel {
    var transferInfo: TransferInfo?
    let repository = ApproveRepository()

    weak var delegate: TransferDetailsViewModelDelegate?
    private var cancellable = Set<AnyCancellable>()

    var isPending: Bool {
        return transferInfo?.status == .PendingSignature
    }

    init(transferInfo: TransferInfo? = nil) {
        self.transferInfo = transferInfo
    }
    
    func setDelegate(delegate: TransferDetailsViewModelDelegate?) {
        self.delegate = delegate
        listenToTransferChanges()
    }
    
    private func listenToTransferChanges() {
        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
            .sink { [weak self] transfers in
                if let self {
                    if let transactionID = self.transferInfo?.transactionID, let transaction = transfers.first(where: {$0.transactionID == transactionID}) {
                        self.transferInfo = transaction
                        self.delegate?.transferDidUpdate()
                    }
                }
            }.store(in: &cancellable)
    }
    
    func approveTransaction() {
        guard let transactionId = transferInfo?.transactionID else { return }
        Task {
            let isApproved = await repository.approveTransaction(transactionId: transactionId)
            self.delegate?.transactionStatusChanged(isApproved: isApproved)
        }
    }
    
    func cancelTransaction() {
        guard let transactionId = transferInfo?.transactionID, let assetId = transferInfo?.assetId else { return }
        Task {
            do {
                let isCanceled = try await repository.cancelTransaction(assetId: assetId, txId: transactionId)
                self.delegate?.transactionCancelStatusChanged(isCanceled: isCanceled)
            } catch {
                self.delegate?.transactionCancelStatusChanged(isCanceled: false)
            }
        }
    }

}
