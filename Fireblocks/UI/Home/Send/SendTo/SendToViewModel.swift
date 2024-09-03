//
//  SendToViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import Foundation
import Combine

protocol SendToViewModelDelegate: AnyObject {
    func addressIsValid(isValid: Bool)
    func refreshData()
}

class SendToViewModel {
    weak var delegate: SendToViewModelDelegate?
    var address: String?
    var transaction: Transaction?
    var transfers: [TransferInfo] = []
    
    var cancellable = Set<AnyCancellable>()

    init() {
        self.transfers = TransfersViewModel.shared.transfers
        self.listenToTransferChanges()
    }
    
    deinit {
        cancellable.removeAll()
    }
    
    private func listenToTransferChanges() {
        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
            .sink { [weak self] transfers in
                if let self {
                    self.filterTransaction(transfers: transfers)
                }
            }.store(in: &cancellable)
    }
    
    var sortedTransfer: [TransferInfo] {
        return transfers.filter({$0.lastUpdated != nil}).sorted(by: {$0.lastUpdated! > $1.lastUpdated!})
    }

    func getTransferFor(index: Int) -> TransferInfo {
        return sortedTransfer[index]
    }

    private func filterTransaction(transfers: [TransferInfo]) {
        guard let transaction = transaction else { return }
        let asset = transaction.asset
        self.transfers = transfers.filter({$0.assetId == asset.id})
        self.delegate?.refreshData()
    }
    
    func getAmountToSendAsString() -> String {
        guard let transaction = transaction else { return "" }
        return String(transaction.amountToSend) + " \(transaction.asset.symbol)"
    }
    
    func getPriceAsString() -> String {
        guard let transaction = transaction else { return "" }
        return String(transaction.price.formatFractions(fractionDigits: 6))
    }
    
    func setAddress(address: String?){
        self.address = address
        checkAddressValid()
    }
    
    func checkAddressValid(){
        if let address = address, !address.isEmpty {
            delegate?.addressIsValid(isValid: true)
        } else {
            delegate?.addressIsValid(isValid: false)
        }
    }
    
    func getTransaction() -> Transaction? {
        guard let address = address else { return nil }
        guard var transaction = transaction else { return nil }
        transaction.receiverAddress = address
        
        return transaction
    }

    func getAsset() -> Asset? {
        guard let transaction = transaction else { return nil }
        return transaction.asset
    }
}
