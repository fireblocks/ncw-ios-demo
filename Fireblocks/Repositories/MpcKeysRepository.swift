//
//  MpcKeysRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/08/2023.
//

import Foundation

class MpcKeysRepository {
    
    func createAssets() async -> Bool {
        var didCreateAsset = false
        let deviceId = FireblocksManager.shared.getDeviceId()
        for asset in AssetType.allCases {
            do {
                let _ = try await SessionManager.shared.createAsset(deviceId: deviceId, assetId: asset.rawValue)
                didCreateAsset = true
            } catch {
                print("Failed to create asset: \(asset.rawValue)")
            }
        }
        return didCreateAsset
    }

}
