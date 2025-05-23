//
//  ApproveRepository.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 23/07/2023.
//

import Foundation

class ApproveRepository {
    let fireblocksManager: FireblocksManager
    
    init(fireblocksManager: FireblocksManager) {
        self.fireblocksManager = fireblocksManager
    }
    
    func approveTransaction(transactionId: String) async throws -> Bool {
        return try await fireblocksManager.signTransaction(transactionId: transactionId)
    }
    
    func stopTransaction() throws {
        try fireblocksManager.stopTransaction()
    }
    
    func cancelTransaction(assetId: String, txId: String) async throws -> Bool {
        let deviceId = fireblocksManager.getDeviceId()
        return try await SessionManager.shared.denyTransaction(deviceId: deviceId, txId: txId)
    }
}
