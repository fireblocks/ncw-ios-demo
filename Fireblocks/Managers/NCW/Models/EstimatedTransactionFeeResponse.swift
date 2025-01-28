//
//  EstimatedTransactionFeeResponse.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation

struct EstimatedTransactionFeeResponse: Codable {
    var low: TransactionFee?
    var medium: TransactionFee?
    var high: TransactionFee?
    
}