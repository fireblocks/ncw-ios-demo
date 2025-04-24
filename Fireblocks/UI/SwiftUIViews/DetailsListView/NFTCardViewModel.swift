//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

extension NFTIconCardView {
    @Observable
    class ViewModel {
        var uiimage: UIImage?
        var image: Image?
        var blockchainImage: Image?
        var iconUrl: String?
        var blockchain: String?
        
        init(iconUrl: String?, blockchain: String?) {
                        
            if let imageURL = iconUrl, let url = URL(string: imageURL) {
                Task {
                    if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.uiimage = uiimage
                            self.image = Image(uiImage: uiimage)
                        }
                    }
                }
            }
            
            guard let blockchain = blockchain else {
                return
            }
            
            loadBlockchainImage(blockchainSymbol: blockchain)

            
            func loadBlockchainImage(blockchainSymbol: String) {
                Task {
                    if let uiImage = await AssetImageLoader.shared.loadAssetImage(symbol: blockchainSymbol, iconUrl: nil) {
                        await MainActor.run {
                            self.blockchainImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
        }        
    }
}


