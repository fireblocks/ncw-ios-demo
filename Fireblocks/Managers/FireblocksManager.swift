//
//  FireblocksManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 10/07/2023.
//

import FireblocksSDK
import FirebaseAuth
import Foundation
import OSLog

private let logger = Logger(subsystem: "Fireblocks", category: "FireblocksManager")
protocol FireblocksKeyCreationDelegate {
    func isKeysGenerated(isGenerated: Bool) async
}

class FireblocksManager {
    
    static let shared = FireblocksManager()
    
    private var deviceId: String = ""
    private var walletId: String = ""

    private init() {
    }
    
    func getDeviceId() -> String {
        return deviceId
    }
    
    func getWalletId() -> String {
        return walletId
    }
    
    func isKeyInitialized(algorithm: Algorithm) -> Bool {
        return getMpcKeys().filter({$0.algorithm == algorithm}).first?.keyStatus == .READY
    }

    func isInstanceInitialized(authUser: AuthUser?) -> Bool {
        guard let deviceId = authUser?.deviceId,
              let walletId = authUser?.walletId
        else {
            logger.log("FireblocksManager, initInstance() failed: user credentials is nil")
            return false
        }
        
        self.deviceId = deviceId
        self.walletId = walletId
        
        do {
            try initializeFireblocksSDK()
            return true
        } catch {
            logger.log("FireblocksManager, initInstance() throws exc: \(error).")
            return false
        }
    }
        
    func getSdkInstance() -> FireblocksSDK.Fireblocks? {
        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            logger.log("FireblocksManager, getFireblocksInstance() can't get instance: \(error).")
            return nil
        }
    }
    
    func generateDeviceId() -> String {
        return Fireblocks.generateDeviceId()
    }
    
    func generatePassphraseId() -> String {
        return Fireblocks.generatePassphraseId()
    }
    
    func generateMpcKeys(_ delegate: FireblocksKeyCreationDelegate) async {
        do {
            let algorithms: Set<Algorithm> = Set([.MPC_ECDSA_SECP256K1])
            let result = try await getSdkInstance()?.generateMPCKeys(algorithms: algorithms)
            let isGenerated = result?.first?.keyStatus == .READY
            await delegate.isKeysGenerated(isGenerated: isGenerated)
        } catch {
            logger.log("FireblocksManager, generateMpcKeys() failed: \(error).")
        }
    }
    
    func signTransaction(transactionId: String) async -> Bool {
        do {
            let result = try await getSdkInstance()?.signTransaction(txId: transactionId)
            return result?.transactionSignatureStatus == .COMPLETED
        } catch {
            logger.log("FireblocksManager, signTransaction() failed: \(error).")
            return false
        }
    }
    
    func getMpcKeys() -> [KeyDescriptor] {
        return getSdkInstance()?.getKeysStatus() ?? []
    }
    
    func getFullKey() async -> [String: Data]? {
        guard getSdkInstance() != nil else {
            return nil
        }
        
        var keysSet: Set<String> = []
        let allKeys = getMpcKeys()
        for mpcKey in allKeys {
            keysSet.insert(mpcKey.keyId)
        }
            
        return nil
    }
    
    func takeOver() async -> Set<FullKey>? {
        guard let instance = getSdkInstance() else {
            return nil
        }
        
        do {
            return try await instance.takeover()
        } catch {
            logger.log("FireblocksManager, Takeover() can't takeover keys: \(error).")
            return nil
        }
    }
    
    func recoverWallet(resolver: FireblocksPassphraseResolver) async -> Bool {
        guard let instance = getSdkInstance() else {
            return false
        }
        
        do {
            let keySet = try await instance.recoverKeys(passphraseResolver: resolver)
            if keySet.isEmpty { return false }
            if keySet.first(where: {$0.keyRecoveryStatus == .ERROR}) != nil  { return false }
            return true
        } catch {
            logger.log("FireblocksManager, recoverWallet() can't recover wallet: \(error).")
            return false
        }
    }
    
    func generatePassphrase() -> String {
        return Fireblocks.generateRandomPassPhrase()
    }
    
    func backupKeys(passphrase: String, passphraseId: String) async -> Set<FireblocksSDK.KeyBackup>? {
        guard let instance = getSdkInstance() else {
            return nil
        }
        
        do {
            return try await instance.backupKeys(passphrase: passphrase, passphraseId: passphraseId)
        } catch {
            logger.log("FireblocksManager, backupKeys(): \(error).")
            return nil
        }
    }
    
    private func initializeFireblocksSDK() throws {
        if getSdkInstance() == nil {
            let _ = try Fireblocks.initialize(
                deviceId: deviceId,
                messageHandlerDelegate: self,
                keyStorageDelegate: KeyStorageProvider(deviceId: self.deviceId),
                fireblocksOptions: FireblocksOptions(env: EnvironmentConstants.env, eventHandlerDelegate: self)
            )
        }
        
        //We simulate a simple way to implement a Polling mechanism.
        //During the integration it is ineeded to generate a mechanism for fetching and listening to incoming messages and transactions, which could be any implementation (e.g. polling, web-socket, push etc.)
        PollingManager.shared.createListener(deviceId: deviceId, instance: self, sessionManager: SessionManager.shared)
        
    }
    
    func stopPollingMessages() {
        PollingManager.shared.removeListener(deviceId: deviceId)
    }

    
    private func isAllKeysBackedUp(_ keyBackupSet: Set<FireblocksSDK.KeyBackup>) -> Bool {
        for status in keyBackupSet {
            if status.keyBackupStatus != .SUCCESS {
                return false
            }
        }
        return true
    }
}

extension FireblocksManager: PollingListenerDelegate {
    func handleTransactions(transactions: [TransactionResponse]) {
        TransfersViewModel.shared.handleTransactions(transactions: transactions)
    }
    
    func lastUpdate() -> TimeInterval? {
        return TransfersViewModel.shared.lastUpdate()
    }
    
    func handleError(error: String?) {
        logger.log("\(error ?? "")")
    }
    
    
}

extension FireblocksManager: MessageHandlerDelegate {
    func handleOutgoingMessage(payload: String, response: @escaping (String?) -> (), error: @escaping (String?) -> ()) {
        Task {
            do {
                let res = try await SessionManager.shared.rpc(
                    deviceId: deviceId,
                    message: payload
                )
                response(res)
            } catch let err {
                error(err.localizedDescription)
            }
        }
    }
        
    private func castByteArrayToString(_ data: Any) -> String? {
        guard let data = data as? [String: Any] else {
            return nil
        }
        
        if let msg = data["message"] as? String {
            return msg.replacingOccurrences(of: "\\", with: "")
        } else {
            return nil
        }
    }
}

extension FireblocksManager: EventHandlerDelegate {
    func onEvent(event: FireblocksSDK.FireblocksEvent) {
        switch event {
        case let .KeyCreation(status, error):
            logger.log("FireblocksManager, status(.KeyCreation): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Backup(status, error):
            logger.log("FireblocksManager, status(.Backup): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Recover(status, error):
            logger.log("FireblocksManager, status(.Recover): \(String(describing: status?.description())). Error: \(String(describing: error)).")
            break
        case let .Transaction(status, error):
            logger.log("FireblocksManager, status(.Transaction): \(status.description()). Error: \(String(describing: error)).")
            break
        @unknown default:
            logger.log("FireblocksManager, @unknown case")
            break
        }
    }
}
