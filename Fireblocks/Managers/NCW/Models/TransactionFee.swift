//
//  TransactionFee.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation

struct TransactionFee: Codable {
    var networkFee: String? = "0"
    var feePerByte: String? = "0"
    var priorityFee: String? = "0"
    var baseFee: String? = "0"
    var gasPrice: String? = "0"
}