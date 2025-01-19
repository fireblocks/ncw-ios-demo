//
//  AssetSummary.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

import UIKit
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct AssetSummary: Codable, Identifiable, Hashable {
    static func == (lhs: AssetSummary, rhs: AssetSummary) -> Bool {
        lhs.asset?.id == rhs.asset?.id
    }
    
    var asset: Asset?
    var address: AddressDetails?
    var balance: AssetBalance?
    var isExpanded: Bool? = false
    var iconUrl: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: String {
        return asset?.id ?? ""
    }
    
    var image: UIImage {
        let assetImage = AssetsImageMapper().getIconForAsset(id)
        return assetImage
    }

}
