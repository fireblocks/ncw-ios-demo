//
//  AddAssetsDelegate.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 16/01/2025.
//

#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

protocol AddAssetsDelegate: AnyObject {
    func didLoadAssets()
    func failedToLoadAssets()
    func reloadData()
    func didAddAssets(addedAssets: [Asset], failedAssets: [Asset])
}
