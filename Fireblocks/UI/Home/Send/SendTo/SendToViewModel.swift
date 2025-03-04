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
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?

    weak var delegate: SendToViewModelDelegate?
    var address: String?
    var transaction: FBTransaction
    
    init(transaction: FBTransaction = FBTransaction()) {
        self.transaction = transaction
    }
    
    func getAmountToSendAsString() -> String {
        return String(transaction.amountToSend) + " \(transaction.asset.asset?.symbol ?? "")"
    }
    
    func getPriceAsString() -> String {
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
    
    func getTransaction() -> FBTransaction? {
        guard let address = address else { return nil }
        transaction.receiverAddress = address
        
        return transaction
    }

    func getAsset() -> AssetSummary? {
        return transaction.asset
    }
}
