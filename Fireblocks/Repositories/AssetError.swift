//
//  AssetError.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation

enum AssetError: Error {
    case failedToGetFee(assetId: String)
    case failedToCreateTransaction(assetId: String)
}