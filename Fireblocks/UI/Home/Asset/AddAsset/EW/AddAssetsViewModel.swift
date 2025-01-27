//
//  AddAssetsViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 16/01/2025.
//

import Foundation
import UIKit
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

class AddAssetsViewModel: ObservableObject {
    private let deviceId: String
    private var assets: [AssetToAdd] = []
    private var searchResults: [AssetToAdd] = []
    private var addedAssets: [Asset] = []
    private var failedAssets: [Asset] = []

    weak var delegate: AddAssetsDelegate?
    var ewManager = EWManager()
    
    init(deviceId: String) {
        self.deviceId = deviceId
        

        Task {
            let response = await ewManager.fetchAllSupportedAssets()
            self.assets = response.map({AssetToAdd(asset: AssetSummary(asset: $0))})
            self.searchResults = response.map({AssetToAdd(asset: AssetSummary(asset: $0))})
            self.delegate?.didLoadAssets()
        }
    }
        
    func getAssetsCount() -> Int {
        return searchResults.count
    }
    
    func getAssets() -> [AssetToAdd] {
        return searchResults
    }
    
    func getSelectedCount() -> Int {
        return assets.filter({$0.isSelected}).count
    }
    
    func didSelect(indexPath: IndexPath) {
        //TBD - can be removed when switch to multi selection
        if !searchResults[indexPath.row].isSelected {
            if let index = searchResults.firstIndex(where: {$0.isSelected}) {
                searchResults[index].isSelected = false
            }
            if let index = assets.firstIndex(where: {$0.isSelected}) {
                assets[index].isSelected = false
            }
        }
        //
        
        searchResults[indexPath.row].isSelected.toggle()
        if let index = assets.firstIndex(where: {$0.asset == searchResults[indexPath.row].asset}) {
            assets[index].isSelected.toggle()
        }
        delegate?.reloadData()
    }
    
    func createAsset() {
        Task {
            let accounts = await ewManager.fetchAllAccounts()
            if accounts.count == 0 {
                let _ = await ewManager.createAccount()
            }
            
            for assetSummary in assets.filter({$0.isSelected}).map({$0.asset}) {
                if let asset = assetSummary.asset {
                    if let _ = await ewManager.addAsset(assetId: assetSummary.id, accountId: 0) {
                        addedAssets.append(asset)
                    } else {
                        failedAssets.append(asset)
                    }
                }
            }
            self.delegate?.didAddAssets(addedAssets: self.addedAssets, failedAssets: self.failedAssets)
        }

    }
    
    func searchDidChange(searchText: String) {
        if searchText.isEmpty {
            searchResults = assets
        } else {
            searchResults = assets.filter({$0.asset.asset != nil && $0.asset.asset!.name != nil && $0.asset.asset!.symbol != nil}).filter({$0.asset.asset!.name!.localizedStandardContains(searchText) || $0.asset.asset!.symbol!.localizedStandardContains(searchText) })
        }
        
        self.delegate?.reloadData()
    }

}
