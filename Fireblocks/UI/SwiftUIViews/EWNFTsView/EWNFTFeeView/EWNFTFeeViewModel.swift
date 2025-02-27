//
//  EWNFTFeeViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

extension EWNFTFeeView {
    @Observable
    class ViewModel {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var token: TokenOwnershipResponse
        var image: Image?
        var uiimage: UIImage?
        var address: String
        var feeLevel: FeeLevel = .LOW
        
        init(token: TokenOwnershipResponse, address: String) {
            self.token = token
            self.address = address
        }
        
        func speed(level: FeeLevel) -> String {
            switch level {
            case .LOW:
                return "Slow"
            case .MEDIUM:
                return "Medium"
            case .HIGH:
                return "Fast"
            @unknown default:
                return "Slow"
            }
        }
        
        func setup(loadingManager: LoadingManager, ewManager: EWManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
            getNFT()
        }

        func getNFT() {
            self.loadingManager.isLoading = true
            Task {
                if let imageURL = token.media?.first?.url, let url = URL(string: imageURL) {
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
        
        func proceedToFee() {
            if !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                
            }
        }
    }
}
