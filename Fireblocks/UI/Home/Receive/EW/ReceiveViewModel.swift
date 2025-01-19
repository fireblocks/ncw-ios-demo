//
//  ReceiveViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

import Foundation

#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

class ReceiveViewModel {
    var asset: AssetSummary!
    
    func getAssetAddress() -> String {
        return asset.address?.address ?? ""
    }
}

