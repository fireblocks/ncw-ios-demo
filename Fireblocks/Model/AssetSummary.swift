//
//  AssetSummary.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

import UIKit
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct AssetSummary: Codable, Identifiable, Hashable {
    static func == (lhs: AssetSummary, rhs: AssetSummary) -> Bool {
        lhs.asset?.id == rhs.asset?.id && lhs.isExpanded == rhs.isExpanded
    }
    
    var asset: Asset?
    var address: AddressDetails?
    var balance: AssetBalance?
    var iconUrl: String?
    var isExpanded: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum MessageError: Error {
        case asset, address, balance, isExpanded, iconURL
    }

    init(asset: Asset? = nil, address: AddressDetails? = nil, balance: AssetBalance? = nil, isExpanded: Bool = false, iconUrl: String? = nil) {
        self.asset = asset
        self.address = address
        self.balance = balance
        self.isExpanded = isExpanded
        self.iconUrl = iconUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.asset = try? container.decode(Asset.self, forKey: .asset)
        self.address = try? container.decode(AddressDetails.self, forKey: .address)
        self.balance = try? container.decode(AssetBalance.self, forKey: .balance)
        self.iconUrl = try? container.decode(String.self, forKey: .iconUrl)

    }

    var id: String {
        return asset?.id ?? ""
    }
    
    var image: UIImage {
        let assetImage = AssetsImageMapper().getIconForAsset(id)
        return assetImage
    }

}
