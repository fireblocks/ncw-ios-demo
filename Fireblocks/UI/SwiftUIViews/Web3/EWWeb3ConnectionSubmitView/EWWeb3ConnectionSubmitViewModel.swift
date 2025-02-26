//
//  EWWeb3ConnectionSubmitViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 24/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

extension EWWeb3ConnectionSubmitView {
    @Observable
    class ViewModel {
        var coordinator: Coordinator!
        var loadingManager: LoadingManager!
        var ewManager: EWManager!
        var response: CreateWeb3ConnectionResponse
        var uiimage: UIImage?
        var image: Image?
        init(response: CreateWeb3ConnectionResponse) {
            self.response = response
            if let imageURL = response.sessionMetadata?.appIcon, let url = URL(string: imageURL) {
                Task {
                    if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.uiimage = uiimage
                            self.image = Image(uiImage: uiimage)
                        }
                    }
                }
            }

        }
        
        func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
        }
        
        func discard() {
            if let id = response.id {
                Task {
                    let _ = await self.ewManager?.submitConnection(id: id, approve: false)
                }
                coordinator.path = NavigationPath()
            }
        }
        
        func submitConnection(approve: Bool) {
            if let id = response.id {
                self.loadingManager.isLoading = true
                Task {
                    let didSubmitConnection = await self.ewManager?.submitConnection(id: id, approve: approve)
                    if didSubmitConnection != nil {
                        if approve {
                            let connections = await self.ewManager.getConnections()
                            if let _ = connections?.data?.first(where: {$0.id == id}) {
                                await MainActor.run {
                                    coordinator.path = NavigationPath()
                                }
                            }
                        } else {
                            await MainActor.run {
                                coordinator.path = NavigationPath()
                            }
                        }
                    }
                    await MainActor.run {
                        self.loadingManager.isLoading = false
                    }
                }
            }
        }
    }
}
