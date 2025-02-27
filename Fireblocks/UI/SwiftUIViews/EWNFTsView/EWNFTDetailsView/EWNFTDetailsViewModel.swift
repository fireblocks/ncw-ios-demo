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
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var dataModel: NFTDataModel
        var image: Image?
        var uiimage: UIImage?
        var didLoad = false
        
        init(dataModel: NFTDataModel) {
            self.dataModel = dataModel
        }
        
        func setup(loadingManager: LoadingManager, ewManager: EWManager, coordinator: Coordinator) {
            if !didLoad {
                didLoad = true
                self.loadingManager = loadingManager
                self.ewManager = ewManager
                self.coordinator = coordinator
                self.loadingManager.isLoading = true
            }
            getNFT()
        }

        func getNFT() {
            Task {
                if let imageURL = dataModel.token?.media?.first?.url, let url = URL(string: imageURL) {
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
        
        func proceedToTransfer() {
            coordinator.path.append(NavigationTypes.transferNFT(dataModel))
        }
        
    }
}
