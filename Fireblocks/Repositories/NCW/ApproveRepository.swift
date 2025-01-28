//
//  ApproveRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 23/07/2023.
//

import Foundation

class ApproveRepository {
    
    func approveTransaction(transactionId: String) async -> Bool {
        return await FireblocksManager.shared.signTransaction(transactionId: transactionId)
    }
    
    func stopTransaction() {
        FireblocksManager.shared.stopTransaction()
    }
    
    func cancelTransaction(assetId: String, txId: String) async throws -> Bool {
        let deviceId = FireblocksManager.shared.getDeviceId()
        return try await SessionManager.shared.denyTransaction(deviceId: deviceId, txId: txId)
    }
}
