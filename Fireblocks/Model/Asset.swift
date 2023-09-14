//
//  AssetModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/06/2023.
//

import Foundation
import UIKit.UIImage

struct Asset: Codable {
    var id: String = ""
    var symbol: String = ""
    var name: String
    var decimals: Int = 0
    var testnet = false
    var hasFee = false
    let type: String
    var issuerAddress: String?
    var blockchainSymbol: String?
    var coinType: Int?
    var blockchain = ""
    var ethContractAddress: String?
    var ethNetwork: String?
    var networkProtocol = ""
    var baseAsset = ""
    var rate: Double? = 1.0
    var fee: FeeResponse?
    var balance: Double?
    var price: Double?
    var address: String?

    var image: UIImage {
        let assetImage = AssetsImageMapper().getIconForAsset(symbol)
        return assetImage
    }
    
//    let image: UIImage
//    let abbreviation: String
//    let blockchainName: String
//    let quantity: Double
//    let price: Double
//    var address: String?
}

struct AssetBalance: Codable {
    var id: String
    var total: String = "0"
    var frozen: String = "0"
    var locked: String = "0"
    var pending: String = "0"
    var staked: String = "0"
    var reserved: String = "0"
}

struct AssetAddress: Codable {
    var address: String
}

