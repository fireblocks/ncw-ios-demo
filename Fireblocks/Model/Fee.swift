//
//  Fee.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation

enum FeeRateType: String, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
}

struct Fee {
    let feeRateType: FeeRateType
    let fee: String
    
    func getFeeName() -> String {
        return feeRateType.rawValue.lowercased().capitalized()
    }
}

struct FeeResponse: Codable {
    var low: FeeData?
    var medium: FeeData?
    var high: FeeData?
}

struct FeeData: Codable {
    var networkFee: String? = "0"
    var feePerByte: String? = "0"
    var priorityFee: String? = "0"
    var baseFee: String? = "0"
    var gasPrice: String? = "0"
}

