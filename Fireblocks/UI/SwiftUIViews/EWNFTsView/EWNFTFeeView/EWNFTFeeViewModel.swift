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
        var dataModel: NFTDataModel
        var image: Image?
        var uiimage: UIImage?
        
        init(dataModel: NFTDataModel) {
            self.dataModel = dataModel
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
        }
        
        func createTransaction() {
            if !dataModel.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let assetId = dataModel.token?.id  {
                loadingManager.isLoading = true
                Task {
                    if let transaction = await ewManager?.createOneTimeAddressTransaction(accountId: 0, assetId: assetId, destAddress: dataModel.address, amount: "1", feeLevel: dataModel.feeLevel) {
                        await MainActor.run {
                            dataModel.transaction = transaction
                            coordinator.path.append(NavigationTypes.nftPreview(dataModel))
                        }
                        
                    }
                    await self.loadingManager.setLoading(value: false)

                }
            }
        }
    }
}
