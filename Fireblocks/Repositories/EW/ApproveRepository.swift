//
//  ApproveRepository.swift
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

class ApproveRepository {
    let ewManager: EWManager
    let fireblocksManager: FireblocksManager
    init(ewManager: EWManager, fireblocksManager: FireblocksManager) {
        self.ewManager = ewManager
        self.fireblocksManager = fireblocksManager
    }

    func approveTransaction(transactionId: String) async throws -> Bool {
        return try await fireblocksManager.signTransaction(transactionId: transactionId)
    }
    
    func stopTransaction() throws {
        try fireblocksManager.stopTransaction()
    }
    
    func cancelTransaction(assetId: String, txId: String) async throws -> Bool {
        return try await self.ewManager.cancelTransaction(txId: txId).success == true
    }
}
