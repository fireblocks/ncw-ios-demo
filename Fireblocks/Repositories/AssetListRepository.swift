//
//  AssetListRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 28/06/2023.
//

import Foundation

enum AssetError: Error {
    case failedToGetFee(assetId: String)
    case failedToCreateTransaction(assetId: String)
}

class AssetListRepository {
    lazy var walletID = FireblocksManager.shared.getWalletId()
    let accountID = "0"

    func getAssets() async throws -> [String: AssetSummary] {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let assets = try await SessionManager.shared.getAssets(deviceId: deviceId)
        return assets
    }
    
    func getBalance(assetId: String) async throws -> AssetBalance {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let balance = try await SessionManager.shared.getAssetBalance(deviceId: deviceId, assetId: assetId)
        return balance
    }
    
    func getAddress(assetId: String) async throws -> AddressDetails {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let address = try await SessionManager.shared.getAssetAddress(deviceId: deviceId, assetId: assetId)
        return address
    }

}
