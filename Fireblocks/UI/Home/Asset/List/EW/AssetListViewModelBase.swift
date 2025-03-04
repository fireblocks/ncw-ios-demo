//
//  AssetListViewModelBase.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 04/03/2025.
//

import SwiftUI
import Combine
#if EW
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif
#endif

@Observable
class AssetListViewModelBase {
    var loadingManager: LoadingManager!
    var coordinator: Coordinator!
    var didLoad: Bool = false
    var addAssetPresented: Bool = false
    var assetsSummary: [AssetSummary] = []
    var accountId: Int = 0
    var cancellable = Set<AnyCancellable>()
    var task: Task<Void, Never>?

    func signOut() {
        assetsSummary.removeAll()
        cancellable.removeAll()
    }
    
    deinit {
        task?.cancel()
    }

    func toggleAssetExpanded(asset: AssetSummary, section: Int = 0) {
        if let index = assetsSummary.firstIndex(where: {$0 == asset}) {
            assetsSummary[index].isExpanded.toggle()
        }
    }
    
    func getAssetSummary() -> [AssetSummary] {
        return assetsSummary
    }
    
    func getAssets() -> [AssetSummary] {
        return assetsSummary
    }
    
    func getAssetsCount() -> Int {
        assetsSummary.count
    }
    
    func getIsButtonsEnabled() -> Bool {
        return !assetsSummary.isEmpty
    }
    
    func getAsset(by assetId: String) -> Asset? {
        return assetsSummary.filter({$0.asset != nil}).map({$0.asset!}).first(where: {$0.id == assetId})
    }

    func fetchAssets() {
        fatalError("fetchAssets should be implemented on child class")
    }
    
    func getBalance() -> String {
        fatalError("getBalance should be implemented on child class")
    }
}
