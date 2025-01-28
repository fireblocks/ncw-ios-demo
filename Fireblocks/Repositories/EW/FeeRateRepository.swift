//
//  FeeRateRepository.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//

import Foundation
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class FeeRateRepository {
    func getFeeRates(for assetId: String, amount: String, address: String, feeLevel: FeeRateType? = nil) async throws -> [Fee] {
        let ewManager = EWManager.shared
        let response = await ewManager.estimateOneTimeAddressTransaction(accountId: 0, assetId: assetId, destAddress: address, amount: amount, feeLevel: .LOW)
        if let response {
            return FeeManager.calcFee(feeResponse: response)
        }
        
        throw AssetError.failedToGetFee(assetId: assetId)
    }
    
    func createTransaction(assetId: String, transactionParams: PostTransactionParams) async throws -> CreateTransactionResponse {
        let ewManager = EWManager.shared
        var feeLevel = FeeLevel.LOW
        if let level = transactionParams.feeLevel {
            feeLevel = FeeLevel(rawValue: level) ?? .LOW
        }
        let response = await ewManager.createOneTimeAddressTransaction(accountId: 0, assetId: transactionParams.assetId, destAddress: transactionParams.destAddress, amount: transactionParams.amount, feeLevel: feeLevel)

        if let response {
            return response
        }

        throw AssetError.failedToCreateTransaction(assetId: assetId)
    }
    
}
