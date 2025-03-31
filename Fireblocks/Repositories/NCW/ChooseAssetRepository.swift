//
//  ChooseAssetRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 18/07/2023.
//

import Foundation
class ChooseAssetRepository {
    
    func getAddress(for assetID: String) async throws -> String {
        let deviceId = FireblocksManager.shared.getDeviceId()
        return try await SessionManager.shared.getAssetAddress(deviceId: deviceId, assetId: assetID).address
    }
}
