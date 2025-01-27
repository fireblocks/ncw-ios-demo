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

struct FBTransaction {
    let asset: AssetSummary
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
