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
    
    func calcFee(feeResponse: FeeResponse) -> [Fee] {
        var feeArray: [Fee] = []
        if let feeData = low, let fee = feeData.networkFee {
            feeArray.append(Fee(feeRateType: .low, fee: "\(fee)"))
        }
        if let feeData = medium, let fee = feeData.networkFee {
            feeArray.append(Fee(feeRateType: .medium, fee: "\(fee)"))
        }
        if let feeData = high, let fee = feeData.networkFee {
            feeArray.append(Fee(feeRateType: .high, fee: "\(fee)"))
        }

        return feeArray
    }

}

struct FeeData: Codable {
    var networkFee: String? = "0"
    var feePerByte: String? = "0"
    var priorityFee: String? = "0"
    var baseFee: String? = "0"
    var gasPrice: String? = "0"
}

