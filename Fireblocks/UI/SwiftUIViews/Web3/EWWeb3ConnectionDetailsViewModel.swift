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
        let connection: Web3Connection
        let canRemove: Bool
        
        init(connection: Web3Connection, canRemove: Bool) {
            self.connection = connection
            self.canRemove = canRemove
        }
        
        func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
        }
        
        func removeConnection() {
            if let id = connection.id {
                self.loadingManager.isLoading = true
                Task {
                    let didRemove = await self.ewManager?.removeConnection(id: id)
                    await MainActor.run {
                        if didRemove != nil {
                            coordinator.path = NavigationPath()
                        }
                        self.loadingManager.isLoading = false
                    }
                }
            }
        }
    }
}
