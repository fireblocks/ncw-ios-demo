
//
//  AssetsIconMapper.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 28/06/2023.
//

import Foundation
import UIKit.UIImage

struct AssetsImageMapper {
    private let cryptoMap = [
        "BTC": AssetsIcons.BitcoinIcon,
        "BTC_TEST": AssetsIcons.BitcoinIcon,
        "ETH": AssetsIcons.EthereumIcon,
        "ETH_TEST3": AssetsIcons.EthereumIcon,
        "SOL": AssetsIcons.SolanaIcon
    ]
    
    func getIconForAsset(_ assetSign: String) -> UIImage {
        return cryptoMap[assetSign]?.getIcon() ?? AssetsIcons.PlaceholderIcon.getIcon()
    }
}
