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
    
    static let mock = FBTransaction(
        asset: AssetSummary(asset: Mocks.AssetMock.getAsset()),
        amountToSend: 100,
        price: 1000,
        receiverAddress: "0x1234567890123456789012345678901234567890",
        fee: nil,
        txId: UUID().uuidString
    )
    
}
