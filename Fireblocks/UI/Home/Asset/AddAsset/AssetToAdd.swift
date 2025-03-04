//
//  AssetToAdd.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct AssetToAdd: Equatable {
    static func == (lhs: AssetToAdd, rhs: AssetToAdd) -> Bool {
        return lhs.asset == rhs.asset
    }

    var asset: AssetSummary
    var isSelected = false
    
    init(asset: Asset) {
        self.asset = AssetSummary(asset: asset)
        self.isSelected = false
    }
}
