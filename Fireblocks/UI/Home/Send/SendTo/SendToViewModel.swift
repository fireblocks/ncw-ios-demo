//
//  SendToViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import Foundation

protocol SendToViewModelDelegate: AnyObject {
    func addressIsValid(isValid: Bool)
}

class SendToViewModel {
    weak var delegate: SendToViewModelDelegate?
    var address: String?
    var transaction: Transaction?
    
    func getAmountToSendAsString() -> String {
        guard let transaction = transaction else { return "" }
        return String(transaction.amountToSend) + " \(transaction.asset.symbol)"
    }
    
    func getPriceAsString() -> String {
        guard let transaction = transaction else { return "" }
        return String(transaction.price.formatWithTwoDecimalPlaces())
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
