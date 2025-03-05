//
//  TransfersViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import Foundation
import UIKit.UIImage

@Observable
class TransfersViewModelBase {
    var transfers: [TransferInfo] = []
    private var task: Task<Void, Never>?

}




final class TransfersViewModel: ObservableObject {
    
    static let shared = TransfersViewModel()
    
    @Published var transfers: [TransferInfo] = []
    weak var delegate: TransfersViewModelDelegate?
    private var task: Task<Void, Never>?
    private var didRequestAlltransactions = false
    deinit {
        task?.cancel()
    }
    
    func signOut() {
        transfers.removeAll()
    }
    
    var sortedTransfers: [TransferInfo] {
        return transfers.filter({$0.lastUpdated != nil}).sorted(by: {$0.lastUpdated! > $1.lastUpdated!})
    }
    
    func listenToTransferChanges() {}
    
    func handleTransactions(transactions: [TransactionResponse]) {
        var didChange = false
        if transfers.isEmpty {
            transfers = transactions.map({TransferInfo.toTransferInfo(response: $0)})
            didChange = true
        } else {
            for transaction in transactions {
                let transferInfo = TransferInfo.toTransferInfo(response: transaction)
                if let index = transfers.firstIndex(where: {$0.transactionID == transferInfo.transactionID}) {
                    if transfers[index].lastUpdated != transferInfo.lastUpdated {
                        transfers[index] = transferInfo
                        didChange = true
                        print("TRANSFER_UPDATED: \(transferInfo)")
                    }

                } else {
                    transfers.append(transferInfo)
                    didChange = true
                    print("TRANSFER_ADDED: \(transferInfo)")
                }
            }
        }
        
        if didChange, transactions.count > 0 {
            updateUI()
        }
    }
    
    func lastUpdate() -> TimeInterval? {
        return transfers.filter({$0.lastUpdated != nil}).map({$0.lastUpdated!}).max()
    }

    func getTransferFor(index: Int) -> TransferInfo {
        return sortedTransfers[index]
    }
    
    func getTransfersCount() -> Int {
        return transfers.count
    }
    
    private func updateUI(){
        if transfers.isEmpty {
            delegate?.showNotification(type: .notification)
        } else {
            delegate?.transfersUpdated()
            AssetListViewModel.shared.fetchAssets()
        }

    }
    
    func refresh() {
    }
    
    func getTransferData(for index: Int) -> TransferInfo {
        return sortedTransfers[index]
    }
    
    func updateStatusWhenApproved(index: Int) {
        transfers[index].status = .confirming
        updateUI()
    }
}
