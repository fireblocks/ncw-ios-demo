//
//  FeeRateRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation

struct EstimatedFeeRequestBody: Codable {
    let assetId: String
    var accountId = "0"
    let destAddress: String
    let amount: String
    var feeLevel: String = FeeRateType.low.rawValue
    var estimateFee: Bool = true
}

class FeeRateRepository {
    func getFeeRates(for assetId: String, amount: String, address: String, feeLevel: FeeRateType? = nil) async throws -> [Fee] {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let payload = EstimatedFeeRequestBody(assetId: assetId, destAddress: address, amount: amount)
        let response = try await SessionManager.shared.estimateFee(deviceId: deviceId, body: payload.dictionary())
        if let feeResponse = response?.fee {
            return feeResponse.calcFee(feeResponse: feeResponse)
        }
        
        throw AssetError.failedToGetFee(assetId: assetId)
    }
    
    func createTransaction(assetId: String, transactionParams: PostTransactionParams) async throws -> CreateTransactionResponse {
        let deviceId = FireblocksManager.shared.getDeviceId()
        if let response = try await SessionManager.shared.createTransaction(deviceId: deviceId, body: transactionParams.dictionary()) {
            return response
        }

        throw AssetError.failedToCreateTransaction(assetId: assetId)
    }
    
}
