//
//  Transaction.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct FBTransaction: Equatable, Hashable {
    static func == (lhs: FBTransaction, rhs: FBTransaction) -> Bool {
        lhs.txId == rhs.txId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(txId)
    }

    var asset: AssetSummary = AssetSummary()
    var amountToSend: Double = 0
    var price: Double = 0
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
