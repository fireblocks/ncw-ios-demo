//
//  EWNFTsViewModel.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import Foundation
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

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
        var coordinator: Coordinator?
        var ewManager: EWManager?
        var loadingManager: LoadingManager?
        var didLoad = false
        var selectedViewOption: ViewAsOptions = .List
        var selectedSortingOption: SortingDateOptions = .ASC

        var dataModel = NFTDataModel()

        func setup(loadingManager: LoadingManager, ewManager: EWManager, coordinator: Coordinator) {
            if !didLoad {
                didLoad = true
                self.loadingManager = loadingManager
                self.ewManager = ewManager
                self.coordinator = coordinator
                self.loadingManager?.isLoading = true
            }

            Task {
                await fetchAllTokens()
            }
        }

        func fetchAllTokens() async {
            do {
                self.dataModel.tokens = try await self.ewManager?.getOwnedNFTs().data ?? []
            } catch {
                await self.loadingManager?.setAlertMessage(error: error)
            }
            await self.loadingManager?.setLoading(value: false)
        }
        
        func sortedTokens() -> [TokenOwnershipResponse] {
            switch selectedSortingOption {
            case .ASC:
                return dataModel.tokens.sorted(by: { $0.ownershipStartTime ?? 0 < $1.ownershipStartTime ?? 0 })
            case .DESC:
                return dataModel.tokens.sorted(by: { $0.ownershipStartTime ?? 0 > $1.ownershipStartTime ?? 0 })
            }
        }
        
        func proceedToDetails() {
            coordinator?.path.append(NavigationTypes.NFTToken(dataModel))

        }
        
    }
}
