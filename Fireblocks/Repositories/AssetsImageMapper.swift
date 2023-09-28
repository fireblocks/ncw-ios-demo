
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
        "WETH_TEST": AssetsIcons.EthereumIcon,
        "ETH_TEST5": AssetsIcons.EthereumIcon,
        "SOL": AssetsIcons.SolanaIcon,
        "SOL_TEST": AssetsIcons.SolanaIcon,
        "ADA_TEST": AssetsIcons.AdaIcon,
        "AVAX_TEST": AssetsIcons.AvaxIcon,
        "MATIC_POLYGON_MUMBAI": AssetsIcons.MaticIcon,        
        "USDT_TEST": AssetsIcons.USDTIcon,
        "USDC_TEST": AssetsIcons.USDCIcon,
        "DAI_TEST": AssetsIcons.DaiIcon,
        "SHIB_TEST": AssetsIcons.ShibIcon,
        "UNI_ETH_TEST3_EB3S": AssetsIcons.UniIcon,
        "XRP_TEST": AssetsIcons.XrpIcon,
        "DOT_TEST": AssetsIcons.DotIcon,
        "CELO_BAK": AssetsIcons.CeloAlfIcon,
        "CELO_ALF": AssetsIcons.CeloAlfIcon

    ]
    
    func getIconForAsset(_ assetSign: String) -> UIImage {
        return cryptoMap[assetSign]?.getIcon() ?? AssetsIcons.PlaceholderIcon.getIcon()
    }
}
