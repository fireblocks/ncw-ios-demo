//
//  FeeRateRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation

class FeeRateRepository {
    func getFeeRates(for assetId: String, amount: String, address: String, feeLevel: FeeLevel? = nil) async throws -> [Fee] {
        let deviceId = FireblocksManager.shared.getDeviceId()
        let payload = EstimatedFeeRequestBody(assetId: assetId, destAddress: address, amount: amount)
        let response = try await SessionManager.shared.estimateFee(deviceId: deviceId, body: payload.dictionary())
        if let feeResponse = response?.fee {
            return FeeManager.calcFee(feeResponse: feeResponse)
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
