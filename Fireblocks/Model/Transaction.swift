//
//  Transaction.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation

struct Transaction {
    let asset: Asset
    let amountToSend: Double
    let price: Double
    var receiverAddress: String?
    var fee: Fee?
    var txId: String?
    
    var isTransferred: Bool = false
    var transferFee: Double?
    
    func getFee() -> Double? {
        guard let fee = fee?.fee else { return nil }
        return Double(fee)
    }
    
}
