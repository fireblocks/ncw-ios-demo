//
//  EstimatedFeeRequestBody.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation

struct EstimatedFeeRequestBody: Codable {
    let assetId: String
    var accountId = "0"
    let destAddress: String
    let amount: String
    var feeLevel: String = FeeRateType.low.rawValue
    var estimateFee: Bool = true
}