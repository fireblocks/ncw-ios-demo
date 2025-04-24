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
    var blockchainImage: Image?
    #if EW
    var loadingManager: LoadingManager?
    var ewManager: EWManager?
    #endif
    
    init(asset: AssetSummary) {
        self.asset = asset
        loadAsset()
    }
    
    private func loadAsset() {
        print("DID CALL loadAsset \(asset.id)")
        Task {
            let assetSymbol = asset.asset?.symbol ?? ""
            let blockchainSymbol = asset.asset?.blockchain ?? ""

            if let uiImage = await AssetImageLoader.shared.loadAssetImage(symbol: assetSymbol, iconUrl: asset.iconUrl) {
                await MainActor.run {
                    self.image = Image(uiImage: uiImage)
                }
            }
            
            if let uiImage = await AssetImageLoader.shared.loadAssetImage(symbol: blockchainSymbol, iconUrl: nil, isBlockchain: true) {
                await MainActor.run {
                    self.blockchainImage = Image(uiImage: uiImage)
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
                    await self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
    }
    #endif
}
