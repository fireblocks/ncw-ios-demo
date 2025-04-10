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
            let blockchainImage = AssetsImageMapper().getIconForAsset(blockchain, isBlockchain: true)
            self.blockchainImage = Image(uiImage: blockchainImage)
            let blockchainImageURL: String? = SessionManager.shared.constructImageURL(iconUrl: nil, symbol: blockchain)
            
            if let blockchainImageURL = blockchainImageURL, let url = URL(string: blockchainImageURL) {
                Task {
                    if let blockchainUIImage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.blockchainImage = Image(uiImage: blockchainUIImage)
                        }
                    }
                }
            }
        }
        
    }
}


