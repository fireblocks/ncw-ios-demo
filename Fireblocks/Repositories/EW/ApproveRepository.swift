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
    let ewManager = EWManager.shared

    func approveTransaction(transactionId: String) async -> Bool {
        return await FireblocksManager.shared.signTransaction(transactionId: transactionId)
    }
    
    func stopTransaction() {
        FireblocksManager.shared.stopTransaction()
    }
    
    func cancelTransaction(assetId: String, txId: String) async throws -> Bool {
        return await self.ewManager.cancelTransaction(txId: txId)?.success == true
    }
}
