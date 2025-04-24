//
//  AddAssetsViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/10/2023.
//

import Foundation
import UIKit


@Observable
class AddAssetsViewModel: AddAssetsViewModelBase {
    private var deviceId: String = ""
    
    func setup(loadingManager: LoadingManager, deviceId: String) {
        self.loadingManager = loadingManager
        self.deviceId = deviceId
        self.loadingManager?.isLoading = true

        Task {
            do {
                let response = try await SessionManager.shared.getSupportedAssets(deviceId: deviceId)
                await MainActor.run {
                    self.assets = response.map({AssetToAdd(asset: $0)})
                    self.searchResults = response.map({AssetToAdd(asset: $0)})
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
                if let assetToAdd = assets.filter({$0.isSelected}).first {
                    if let _ = try await SessionManager.shared.createAsset(deviceId: deviceId, assetId: assetToAdd.asset.id) {
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

