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
            Task {
                await getNFT()
            }
        }

        func getNFT() async {
            self.loadingManager.isLoading = true
            self.token = await self.ewManager.getNFT(id: id)
            if let imageURL = token?.media?.first?.url, let url = URL(string: imageURL) {
                if let data = try? Data(contentsOf: url) {
                    if let uiimage = UIImage(data: data) {
                        self.uiimage = uiimage
                        self.image = Image(uiImage: uiimage)
                    }
                }
            }
            
            if self.image == nil {
                self.image = Image("globe")
            }

            self.loadingManager.isLoading = false
        }
        
    }
}
