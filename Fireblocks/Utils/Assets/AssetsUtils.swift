//
//  AssetsUtils.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 02/04/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif


class AssetsUtils {
    
    static func getAssetTitleText(asset: Asset?) -> String {
        guard let asset = asset else {
            return ""
        }
        var title = asset.symbol
        title = removeTestSuffix(title ?? "")
        
        if let blockchain = BlockchainProvider.shared.getBlockchain(blockchainName: asset.blockchain ?? "") {
            title! += " (\(blockchain.displayName))"
            
        }
        
        return title!
        
                
    }

    static func removeTestSuffix(_ title: String) -> String {
        var title = title
        if title.contains("_TEST") {
            title = title.replacingOccurrences(of: "_TEST\\d*$", with: "", options: .regularExpression)
        }
        return title
    }
    
    static func getBlockchainDisplayName(blockchainName: String?) -> String {
        if let blockchain = BlockchainProvider.shared.getBlockchain(blockchainName: blockchainName ?? "") {
            return blockchain.displayName
        }
        return ""
    }

}

