//
//  EWNFTsViewModel.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import Foundation
import EmbeddedWalletSDKDev

extension EWNFTsView {
    @Observable
    class ViewModel {
        var ewManager: EWManager = EWManager.shared
        var loadingManager: LoadingManager!
        var tokens: [TokenOwnershipResponse] = []
        var didLoad = false
        
        
        func setup(loadingManager: LoadingManager) {
            guard !didLoad else { return }
            didLoad = true
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            Task {
                await fetchAllTokens()
            }
        }

        func fetchAllTokens() async {
            await self.loadingManager.setLoading(value: true)
            self.tokens = await self.ewManager.getOwnedNFTs()?.data ?? []
            await self.loadingManager.setLoading(value: false)
        }
        
    }
}
