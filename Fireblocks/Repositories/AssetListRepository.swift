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

enum AssetType: String, CaseIterable {
    case BTC_TEST
    case ETH_TEST3
    
    func calcFee(feeResponse: FeeResponse) -> [Fee] {
        var feeArray: [Fee] = []
        
        switch self {
        case .BTC_TEST:
            break
        case .ETH_TEST3:
            if let feeData = feeResponse.low, let fee = calcFeeFromData(feeData: feeData) {
                feeArray.append(Fee(feeRateType: .low, fee: "\(fee)"))
            }
            if let feeData = feeResponse.medium, let fee = calcFeeFromData(feeData: feeData) {
                feeArray.append(Fee(feeRateType: .medium, fee: "\(fee)"))
            }
            if let feeData = feeResponse.high, let fee = calcFeeFromData(feeData: feeData) {
                feeArray.append(Fee(feeRateType: .high, fee: "\(fee)"))
            }
        }
        return feeArray
    }
    
    private func calcFeeFromData(feeData: FeeData) -> Double? {
        switch self {
        case .BTC_TEST:
            return Double(feeData.networkFee ?? "0")?.formatFractions(fractionDigits: 6) ?? 0
        case .ETH_TEST3:
            return Double(feeData.networkFee ?? "0")?.formatFractions(fractionDigits: 6) ?? 0
//            if let baseFee = feeData.baseFee, let priorityFee = feeData.priorityFee {
//                let decimalValue = NSDecimalNumber(string: baseFee)
//                return Double(truncating:decimalValue)
//            }
        }
    }
}

class AssetListRepository {
    lazy var walletID = FireblocksManager.shared.getWalletId()
    let accountID = "0"
    
    func createAssets() async {
        let deviceId = FireblocksManager.shared.getDeviceId()
        for asset in AssetType.allCases {
            do {
                let _ = try await SessionManager.shared.createAsset(deviceId: deviceId, assetId: asset.rawValue)
            } catch {
                print("Failed to create asset: \(asset.rawValue)")
            }
        }
    }

    func getAssets() async throws -> [Asset] {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let assets = try await SessionManager.shared.getAssets(deviceId: deviceId)
        return assets
    }
    
    func getBalance(assetId: String) async throws -> AssetBalance {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let balance = try await SessionManager.shared.getAssetBalance(deviceId: deviceId, assetId: assetId)
        return balance
    }
    
    func getAddress(assetId: String) async throws -> AssetAddress {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let address = try await SessionManager.shared.getAssetAddress(deviceId: deviceId, assetId: assetId)
        return address
    }

}
