//
//  EWNFTCardViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 26/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

extension EWNFTCard {
    @Observable
    class ViewModel {
        var uiimage: UIImage?
        var image: Image?
        let token: TokenOwnershipResponse
        init(token: TokenOwnershipResponse) {
            self.token = token
            
            if let imageURL = token.media?.first?.url, let url = URL(string: imageURL) {
                Task {
                    if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.uiimage = uiimage
                            self.image = Image(uiImage: uiimage)
                        }
                    }
                }
            }
        }
        
    }
}
