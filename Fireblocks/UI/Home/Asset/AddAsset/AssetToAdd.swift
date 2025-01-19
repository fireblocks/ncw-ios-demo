//
//  AssetToAdd.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct AssetToAdd {
    var asset: AssetSummary
    var isSelected = false
}
