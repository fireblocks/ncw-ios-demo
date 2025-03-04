//
//  ReceiveViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 16/07/2023.
//

import Foundation

class ReceiveViewModel {
    var loadingManager: LoadingManager?
    var asset: AssetSummary
    
    init(asset: AssetSummary = AssetSummary()) {
        self.asset = asset
    }

    func getAssetAddress() -> String {
        return asset.address?.address ?? ""
    }
}
