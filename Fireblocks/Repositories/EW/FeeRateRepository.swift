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
    let ewManager: EWManager
    init(ewManager: EWManager) {
        self.ewManager = ewManager
    }
    
    func getFeeRates(for assetId: String, amount: String, address: String, feeLevel: FeeLevel? = nil) async throws -> [Fee] {
        let response = try await ewManager.estimateOneTimeAddressTransaction(accountId: 0, assetId: assetId, destAddress: address, amount: amount, feeLevel: .LOW)
        return FeeManager.calcFee(feeResponse: response)
    }
    
    func createTransaction(assetId: String, transactionParams: PostTransactionParams) async throws -> CreateTransactionResponse {
        var feeLevel = FeeLevel.LOW
        if let level = transactionParams.feeLevel {
            feeLevel = FeeLevel(rawValue: level) ?? .LOW
        }
        let response = try await ewManager.createOneTimeAddressTransaction(accountId: 0, assetId: transactionParams.assetId, destAddress: transactionParams.destAddress, amount: transactionParams.amount, feeLevel: feeLevel)
        return response
    }
    
}
