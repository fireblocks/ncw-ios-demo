//
//  ReceiveViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

import Foundation
#if EW
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif
#endif
class ReceiveViewModel {
    var loadingManager: LoadingManager?
    var asset: AssetSummary
    
    init(asset: AssetSummary = AssetSummary()) {
        self.asset = asset
    }
    
    func getAssetAddress() -> String {
        return asset.address?.address ?? ""
    }
}

