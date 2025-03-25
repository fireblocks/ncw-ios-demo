//
//  EWTransferNFTViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

extension EWTransferNFTView {
    @Observable
    class ViewModel: QRCodeScannerViewControllerDelegate {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var dataModel: NFTDataModel
        var image: Image?
        var uiimage: UIImage?
        var isQRPresented = false
        
        init(dataModel: NFTDataModel) {
            self.dataModel = dataModel
        }
        
        func setup(loadingManager: LoadingManager, ewManager: EWManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
        }

        func presentQRCodeScanner() {
            self.isQRPresented = true
        }
        
        func proceedToFee() {
            if !dataModel.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                coordinator.path.append(NavigationTypes.nftFee(dataModel))
            }
        }

        
        //MARK: QRCodeScannerViewControllerDelegate -
        static func == (lhs: EWTransferNFTView.ViewModel, rhs: EWTransferNFTView.ViewModel) -> Bool {
            lhs.dataModel.address == rhs.dataModel.address
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(dataModel.address)
        }

        @MainActor
        func gotAddress(address: String) {
            isQRPresented = false
            dataModel.address = address
            proceedToFee()
        }

    }
}
