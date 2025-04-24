//
//  EWWeb3ConnectionURIModel.swift
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

extension EWWeb3ConnectionURI {
    @Observable
    class ViewModel {
        var coordinator: Coordinator?
        var loadingManager: LoadingManager?
        var ewManager: EWManager?
        var dataModel: Web3DataModel
        
        init(dataModel: Web3DataModel) {
            self.dataModel = dataModel
        }

        func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.ewManager = ewManager
            self.coordinator = coordinator
        }
        
        func createConnection() {
            if !dataModel.uri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.loadingManager?.isLoading = true
                Task {
                    do {
                        dataModel.response = try await self.ewManager?.createConnection(feeLevel: .medium, uri: dataModel.uri, ncwAccountId: dataModel.accountId)
                        await MainActor.run {
                            if dataModel.response != nil {
                                self.coordinator?.path.append(NavigationTypes.submitConnection(dataModel))
                            }
                            self.loadingManager?.isLoading = false
                        }
                    } catch {
                        await self.loadingManager?.setAlertMessage(error: error)
                    }
                    await self.loadingManager?.setLoading(value: false)
                }
            }
        }
    }
    
    
}
