//
//  EWTransferNFTViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

extension EWTransferNFTView {
    @Observable
    class ViewModel: QRCodeScannerViewControllerDelegate {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var token: TokenOwnershipResponse
        var image: Image?
        var uiimage: UIImage?
        var address: String = ""
        var isQRPresented = false
        
        init(token: TokenOwnershipResponse) {
            self.token = token
        }
        
        func setup(loadingManager: LoadingManager, ewManager: EWManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
            getNFT()
        }

        func presentQRCodeScanner() {
            self.isQRPresented = true
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
                coordinator.path.append(NavigationTypes.nftFee(token, address))
            }
        }

        
        //MARK: QRCodeScannerViewControllerDelegate -
        static func == (lhs: EWTransferNFTView.ViewModel, rhs: EWTransferNFTView.ViewModel) -> Bool {
            lhs.address == rhs.address
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(address)
        }

        func gotAddress(address: String) {
            isQRPresented = false
            self.address = address
            proceedToFee()
        }

    }
}
