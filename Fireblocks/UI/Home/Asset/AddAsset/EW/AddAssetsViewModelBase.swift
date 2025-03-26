//
//  AddAssetsViewModelBase.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 04/03/2025.
//


import Foundation
import UIKit
#if EW
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif
#endif

@Observable
class AddAssetsViewModelBase {
    var loadingManager: LoadingManager?

    var assets: [AssetToAdd] = []
    var searchResults: [AssetToAdd] = []
    var selectedAsset: AssetToAdd?
    var searchText = ""
    
    func getAssetsCount() -> Int {
        return searchResults.count
    }
    
    func getSelectedCount() -> Int {
        return assets.filter({$0.isSelected}).count
    }

    func getAssets() -> [AssetToAdd] {
        return searchResults
    }
        
    func didSelect(asset: AssetToAdd) {
        if !asset.isSelected {
            if let index = searchResults.firstIndex(where: {$0.isSelected}) {
                searchResults[index].isSelected = false
            }
            if let index = assets.firstIndex(where: {$0.isSelected}) {
                assets[index].isSelected = false
            }
        }
        
        if let index = searchResults.firstIndex(where: {$0 == asset}) {
            searchResults[index].isSelected.toggle()
            if let index = assets.firstIndex(where: {$0 == asset}) {
                assets[index].isSelected.toggle()
            }
        }
    }
    
    func searchDidChange() {
        if searchText.isEmpty {
            searchResults = assets
        } else {
            searchResults = assets.filter({$0.asset.asset != nil && $0.asset.asset!.name != nil && $0.asset.asset!.symbol != nil}).filter({$0.asset.asset!.name!.localizedStandardContains(searchText) || $0.asset.asset!.symbol!.localizedStandardContains(searchText) })
        }
    }

    func createAsset() {
        fatalError("createAsset should be implemented on child class")

    }
}
