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

@Observable
class AddAssetsViewModel {
    var ewManager: EWManager!
    var loadingManager: LoadingManager!

    private var assets: [AssetToAdd] = []
    var searchResults: [AssetToAdd] = []
    var selectedAsset: AssetToAdd?
    var searchText = ""

    func setup(ewManager: EWManager, loadingManager: LoadingManager) {
        self.ewManager = ewManager
        self.loadingManager = loadingManager
        Task {
            await self.loadingManager.setLoading(value: true)
            do {
                let response = try await self.ewManager?.fetchAllSupportedAssets()
                await MainActor.run {
                    self.assets = response?.map({AssetToAdd(asset: $0)}) ?? []
                    self.searchResults = response?.map({AssetToAdd(asset: $0)}) ?? []
                    self.loadingManager.isLoading = false
                }
            } catch {
                await self.loadingManager.setAlertMessage(error: error)
                await self.loadingManager.setLoading(value: false)
            }
        }
    }
        
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
    
    func createAsset() {
        self.loadingManager.isLoading = true
        Task {
            do {
                let accounts = try await ewManager?.fetchAllAccounts()
                if accounts?.count == 0 {
                    let _ = try await ewManager.createAccount()
                }
                
                if let assetToAdd = assets.filter({$0.isSelected}).first {
                    if let _ = try await ewManager?.addAsset(assetId: assetToAdd.asset.id, accountId: 0) {
                        await MainActor.run {
                            selectedAsset = assetToAdd
                        }
                    }
                    await self.loadingManager.setLoading(value: false)
                }
            } catch {
                await self.loadingManager.setAlertMessage(error: error)
                await self.loadingManager.setLoading(value: false)
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

}
