//
//  EWNFTDetailsView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 20/02/2025.
//


import SwiftUI
import EmbeddedWalletSDKDev

extension EWNFTDetailsView {
    @Observable
    class ViewModel {
        var loadingManager: LoadingManager!
        var ewManager: EWManager = EWManager.shared
        let id: String
        var token: TokenResponse?
        var image: Image?
        var uiimage: UIImage?

        init(id: String) {
            self.id = id
        }
        
        func setup(loadingManager: LoadingManager) {
            self.loadingManager = loadingManager
            getNFT()
        }

        func getNFT() {
            self.loadingManager.isLoading = true
            Task {
                self.token = await self.ewManager.getNFT(id: id)
                if let imageURL = token?.media?.first?.url, let url = URL(string: imageURL) {
                    if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.uiimage = uiimage
                            self.image = Image(uiImage: uiimage)
                            if self.image == nil {
                                self.image = Image("globe")
                            }
                            
                            self.loadingManager.isLoading = false
                        }
                    } else {
                        await self.loadingManager.setLoading(value: false)
                    }
                } else {
                    await self.loadingManager.setLoading(value: false)
                }
                
            }
        }
        
    }
}
