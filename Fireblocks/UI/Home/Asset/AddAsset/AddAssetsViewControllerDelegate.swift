//
//  AddAssetsViewControllerDelegate.swift
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

protocol AddAssetsViewControllerDelegate: AnyObject {
    func dismissAddAssets(addedAssets: [Asset], failedAssets: [Asset])
}
