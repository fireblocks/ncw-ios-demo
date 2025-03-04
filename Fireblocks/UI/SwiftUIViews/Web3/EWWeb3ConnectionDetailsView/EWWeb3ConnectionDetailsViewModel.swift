//
//  EWWeb3ConnectionDetailsViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 24/02/2025.
//
import SwiftUI
import EmbeddedWalletSDKDev

extension EWWeb3ConnectionDetailsView {
    @Observable
    class ViewModel {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var dataModel: Web3DataModel
        
        init(dataModel: Web3DataModel) {
            self.dataModel = dataModel
        }
        
        func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
        }
        
        func removeConnection() {
            if let id = dataModel.connection?.id {
                self.loadingManager.isLoading = true
                Task {
                    do {
                        let didRemove = try await self.ewManager?.removeConnection(id: id)
                        await MainActor.run {
                            if didRemove != nil {
                                coordinator.path = NavigationPath()
                            }
                            self.loadingManager.isLoading = false
                        }
                    } catch {
                        await self.loadingManager.setAlertMessage(error: error)
                    }
                    await self.loadingManager.setLoading(value: false)

                }
            }
        }
    }
}
