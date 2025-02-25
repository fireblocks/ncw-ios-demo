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
        var uri: String = ""
        var response: CreateWeb3ConnectionResponse?
        var isQRPresented = false
        private var accountId: Int
        
        init(accountId: Int) {
            self.accountId = accountId
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
            if !uri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.loadingManager.isLoading = true
                Task {
                    let response = await self.ewManager?.createConnection(feeLevel: .medium, uri: uri, ncwAccountId: accountId)
                    await MainActor.run {
                        if response != nil {
                            self.coordinator.path.append(NavigationTypes.submitConnection(response!))
                        }
                        self.loadingManager.isLoading = false
                    }
                }
            }
        }
    
        //MARK: QRCodeScannerViewControllerDelegate -
        static func == (lhs: EWWeb3ConnectionURI.ViewModel, rhs: EWWeb3ConnectionURI.ViewModel) -> Bool {
            lhs.uri == rhs.uri
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(uri)
        }

        func gotAddress(address: String) {
            isQRPresented = false
            uri = address
            createConnection()
        }

    }
    
    
}
