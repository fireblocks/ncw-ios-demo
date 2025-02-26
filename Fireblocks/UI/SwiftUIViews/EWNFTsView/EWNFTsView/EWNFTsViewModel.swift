//
//  EWNFTsViewModel.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import Foundation
import EmbeddedWalletSDKDev

enum ViewAsOptions: String, CaseIterable {
    case List
    case Gallery
}

enum SortingDateOptions: String, CaseIterable {
    case ASC = "Date ↑"
    case DESC = "Date ↓"
}


extension EWNFTsView {
    @Observable
    class ViewModel {
        var ewManager: EWManager!
        var loadingManager: LoadingManager!
        var tokens: [TokenOwnershipResponse] = []
        var didLoad = false
        var selectedViewOption: ViewAsOptions = .List
        var selectedSortingOption: SortingDateOptions = .ASC

        func setup(loadingManager: LoadingManager, ewManager: EWManager) {
            if !didLoad {
                didLoad = true
                self.loadingManager = loadingManager
                self.ewManager = ewManager
                self.loadingManager.isLoading = true
            }

            Task {
                await fetchAllTokens()
            }
        }

        func fetchAllTokens() async {
            self.tokens = await self.ewManager?.getOwnedNFTs()?.data ?? []
            await self.loadingManager.setLoading(value: false)
        }
        
        func sortedTokens() -> [TokenOwnershipResponse] {
            switch selectedSortingOption {
            case .ASC:
                return tokens.sorted(by: { $0.ownershipStartTime ?? 0 < $1.ownershipStartTime ?? 0 })
            case .DESC:
                return tokens.sorted(by: { $0.ownershipStartTime ?? 0 > $1.ownershipStartTime ?? 0 })
            }
        }
        
    }
}
