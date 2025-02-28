//
//  EWWeb3ConnectionURIModel.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import Foundation
import EmbeddedWalletSDKDev

extension EWWeb3ConnectionURI {
    @Observable
    class ViewModel: QRCodeScannerViewControllerDelegate {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var dataModel: Web3DataModel
        var isQRPresented = false
        
        init(dataModel: Web3DataModel) {
            self.dataModel = dataModel
        }

        func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
        }

        func presentQRCodeScanner() {
            self.isQRPresented = true
        }
        
        func createConnection() {
            if !dataModel.uri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.loadingManager.isLoading = true
                Task {
                    dataModel.response = await self.ewManager?.createConnection(feeLevel: .medium, uri: dataModel.uri, ncwAccountId: dataModel.accountId)
                    await MainActor.run {
                        if dataModel.response != nil {
                            self.coordinator.path.append(NavigationTypes.submitConnection(dataModel))
                        }
                        self.loadingManager.isLoading = false
                    }
                }
            }
        }
    
        //MARK: QRCodeScannerViewControllerDelegate -
        static func == (lhs: EWWeb3ConnectionURI.ViewModel, rhs: EWWeb3ConnectionURI.ViewModel) -> Bool {
            lhs.dataModel.uri == rhs.dataModel.uri
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(dataModel.uri)
        }

        func gotAddress(address: String) {
            isQRPresented = false
            dataModel.uri = address
            createConnection()
        }

    }
    
    
}
