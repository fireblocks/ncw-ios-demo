//
//  PostTransactionParams.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

struct PostTransactionParams: Encodable {
    let assetId: String
    let destAddress: String
    let accountId: String = "0"
    let amount: String
    let note: String
    let feeLevel: String? //LOW, MEDIUM, HIGH
}
