//
//  AssetRowViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 09/03/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

@Observable
class AssetRowViewModel {
    var asset: AssetSummary
    var uiimage: UIImage?
    var image: Image?
    #if EW
    var loadingManager: LoadingManager?
    var ewManager: EWManager?
    #endif
    
    init(asset: AssetSummary) {
        self.asset = asset
        self.uiimage = asset.image
        loadAsset()
    }
    
    private func loadAsset() {
        self.image = Image(uiImage: asset.image)
        Task {
            if let imageURL = asset.iconUrl, let url = URL(string: imageURL) {
                if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                    await MainActor.run {
                        self.uiimage = uiimage
                        self.image = Image(uiImage: uiimage)
                        if self.image == nil {
                            self.image = Image(uiImage: asset.image)
                        }
                        
                    }
                }
            }
        }

    }
    
    #if EW
    func setup(loadingManager: LoadingManager, ewManager: EWManager) {
        self.loadingManager = loadingManager
        self.ewManager = ewManager
    }
    
    func refreshBalance() {
        if let assetId = asset.asset?.id {
            self.loadingManager?.isLoading = true
            Task {
                do {
                    let result = try await ewManager?.refreshAssetBalance(assetId: assetId, accountId: 0)
                    await self.loadingManager?.setLoading(value: false)
                } catch {
                    await self.loadingManager?.setLoading(value: false)
                    await self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
    }
    #endif
}
