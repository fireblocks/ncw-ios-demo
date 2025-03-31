//
//  EWWeb3ConnectionsViewModel.swift
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

extension EWWeb3ConnectionsView {
    @Observable
    class ViewModel {
        var loadingManager: LoadingManager?
        var ewManager: EWManager?
        var didLoad = false
        var dataModel = Web3DataModel()

        var isAddConnectionPresented = false
           
        init(accountId: Int) {
            dataModel.accountId = accountId
        }
        
        func setup(ewManager: EWManager, loadingManager: LoadingManager) {
            if !didLoad {
                didLoad = true
                self.loadingManager = loadingManager
                self.ewManager = ewManager
                self.loadingManager?.isLoading = true
            }
            
            fetchAllConnections()
        }

        func fetchAllConnections() {
            Task {
                do {
                    let connections = try await self.ewManager?.getConnections().data ?? []
                    await MainActor.run {
                        self.dataModel.connections = connections
                        self.loadingManager?.isLoading = false
                    }
                } catch {
                    await self.loadingManager?.setAlertMessage(error: error)
                }
                await self.loadingManager?.setLoading(value: false)
            }
        }
        
        func removeConnection(id: String?) {
            if let id {
                self.loadingManager?.isLoading = true
                Task {
                    do {
                        if let _ = try await self.ewManager?.removeConnection(id: id) {
                            fetchAllConnections()
                        } else {
                            await self.loadingManager?.setLoading(value: false)
                        }
                    } catch {
                        await self.loadingManager?.setAlertMessage(error: error)
                    }
                }
            }
        }
    }
}
