//
//  TransfersViewModelBase.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/03/2025.
//

import Combine
import SwiftUI

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class TransfersViewModelBase: ObservableObject {
    @Published var transfers: [TransferInfo] = []
    var selectedTransfer: TransferInfo?
    var cancellable = Set<AnyCancellable>()

    deinit {
        cancellable.removeAll()
    }
    
    @MainActor
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
                        withAnimation {
                            transfers[index] = transferInfo
                        }
                        didChange = true
                        print("TRANSFER_UPDATED: \(transferInfo)")
                    }

                } else {
                    withAnimation {
                        transfers.append(transferInfo)
                    }
                    didChange = true
                    print("TRANSFER_ADDED: \(transferInfo)")
                }
            }
        }
        
        if didChange, transactions.count > 0 {
            updateUI()
        }
    }

    func signOut() {
        transfers.removeAll()
    }

    var sortedTransfers: [TransferInfo] {
        return transfers.filter({$0.lastUpdated != nil}).sorted(by: {$0.lastUpdated! > $1.lastUpdated!})
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
    
    func updateUI(){
        if !transfers.isEmpty {
            AssetListViewModel.shared.fetchAssets()
        }
    }
    
    func getTransferData(for index: Int) -> TransferInfo {
        return sortedTransfers[index]
    }
    
    func updateStatusWhenApproved(index: Int) {
        transfers[index].status = .confirming
        updateUI()
    }

}
