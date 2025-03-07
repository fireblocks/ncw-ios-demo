//
//  TakeoverViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 19/07/2023.
//

import Foundation
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

protocol TakeoverViewModelDelegate: AnyObject {
    func didReceiveFullKeys(fullKeys: Set<FullKey>?)
}

@Observable
class TakeoverViewModel  {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    var fireblocksManager: FireblocksManager?

    func setup(coordinator: Coordinator, loadingManager: LoadingManager, fireblocksManager: FireblocksManager) {
        self.coordinator = coordinator
        self.loadingManager = loadingManager
        self.fireblocksManager = fireblocksManager
    }
    
    func getTakeoverFullKeys() {
        self.loadingManager?.isLoading = true
        Task {
            if let keys = await fireblocksManager?.takeOver(), keys.count > 0, keys.filter({$0.error != nil}).isEmpty {
                await MainActor.run {
                    self.loadingManager?.isLoading = false
                    self.coordinator?.path.append(NavigationTypes.derivedKeysView(keys))
                }
            } else {
                await MainActor.run {
                    self.loadingManager?.isLoading = false
                    self.loadingManager?.setAlertMessage(error: CustomError.genericError("Failed to takeover keys"))
                }
            }
        }

    }
}
