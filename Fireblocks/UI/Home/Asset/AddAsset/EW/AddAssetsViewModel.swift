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
class AddAssetsViewModel: AddAssetsViewModelBase {
    var ewManager: EWManager?

    func setup(ewManager: EWManager, loadingManager: LoadingManager) {
        self.ewManager = ewManager
        self.loadingManager = loadingManager
        Task {
            await self.loadingManager?.setLoading(value: true)
            do {
                let response = try await self.ewManager?.fetchAllSupportedAssets()
                await MainActor.run {
                    self.assets = response?.map({AssetToAdd(asset: $0)}) ?? []
                    self.searchResults = response?.map({AssetToAdd(asset: $0)}) ?? []
                    self.loadingManager?.isLoading = false
                }
            } catch {
                await self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }
        
    override func createAsset() {
        self.loadingManager?.isLoading = true
        Task {
            do {
                let accounts = try await ewManager?.fetchAllAccounts()
                if accounts?.count == 0 {
                    let _ = try await ewManager?.createAccount()
                }
                
                if let assetToAdd = assets.filter({$0.isSelected}).first {
                    if let _ = try await ewManager?.addAsset(assetId: assetToAdd.asset.id, accountId: 0) {
                        await MainActor.run {
                            selectedAsset = assetToAdd
                        }
                    }
                    await self.loadingManager?.setLoading(value: false)
                }
            } catch {
                await self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }
}
