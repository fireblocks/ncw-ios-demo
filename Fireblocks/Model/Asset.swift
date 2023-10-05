//
//  AssetModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/06/2023.
//

import Foundation
import UIKit.UIImage

struct AssetSummary: Codable {
    var asset: Asset?
    var address: AssetAddress?
    var balance: AssetBalance?
}

struct Asset: Codable, Identifiable, Hashable {
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }

    
    var id: String = ""
    var symbol: String = ""
    var name: String
    var decimals: Int = 0
    var testnet = false
    var hasFee = false
    let type: String
    var deprecated = false
    var coinType: Int?
    var blockchain = ""
    var ethNetwork: String?
    var networkProtocol = ""
    var baseAsset = ""
    var rate: Double? = 1.0
    var fee: FeeResponse?
    var balance: Double?
    var price: Double?
    var address: String?

    var image: UIImage {
        let assetImage = AssetsImageMapper().getIconForAsset(id)
        return assetImage
    }    
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
    var accountId: String?
    var accountName: String?
    var addressType: String?
}
