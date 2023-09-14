//
//  ReceiveViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 16/07/2023.
//

import Foundation

class ReceiveViewModel {
    var asset: Asset!
    
    func getAssetAddress() -> String {
        return asset.address ?? ""
    }
}
