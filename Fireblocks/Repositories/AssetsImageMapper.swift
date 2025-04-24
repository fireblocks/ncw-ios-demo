
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
        "btc": AssetsIcons.BitcoinIcon,
        "eth": AssetsIcons.EthereumIcon,
        "weth": AssetsIcons.EthereumIcon,
        "sol": AssetsIcons.SolanaIcon,
        "ada": AssetsIcons.AdaIcon,
        "avax": AssetsIcons.AvaxIcon,
        "matic": AssetsIcons.MaticIcon,
        "polygon": AssetsIcons.MaticIcon,
        "usdt": AssetsIcons.USDTIcon,
        "usdc": AssetsIcons.USDCIcon,
        "dai": AssetsIcons.DaiIcon,
        "shib": AssetsIcons.ShibIcon,
        "uni": AssetsIcons.UniIcon,
        "xrp": AssetsIcons.XrpIcon,
        "dot": AssetsIcons.DotIcon,
        "celo": AssetsIcons.CeloAlfIcon,
        "basechain": AssetsIcons.BasechainIcon,
        "etherlink": AssetsIcons.EtherlinkIcon
    ]
    
    func getIconForAsset(_ assetSign: String) -> UIImage? {
        return cryptoMap[assetSign]?.getIcon()
    }
    
    func getPlaceHolderImage(assetSign: String, isBlockchain: Bool = false) -> UIImage{
        if (isBlockchain) {
            return AssetsIcons.BlockchainPlaceholderIcon.getIcon()
        } else {
            return AssetsIcons.PlaceholderIcon.getIcon()
        }        
    }
}
