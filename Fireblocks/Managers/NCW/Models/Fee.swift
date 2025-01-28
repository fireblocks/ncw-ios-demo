//
//  Fee.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation

struct Fee {
    let feeRateType: FeeRateType
    let fee: String
    
    func getFeeName() -> String {
        return feeRateType.rawValue.lowercased().capitalized()
    }
}