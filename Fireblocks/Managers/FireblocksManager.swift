//
//  FireblocksManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 10/07/2023.
//

import FireblocksSDK
import FirebaseAuth
import Foundation

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
    
    func isKeyInitialized() -> Bool {
        return getMpcKeys().first?.keyStatus == .READY
    }

    func isInstanceInitialized(authUser: AuthUser?) -> Bool {
        guard let deviceId = authUser?.deviceId,
              let walletId = authUser?.walletId
        else {
            print("FireblocksManager, initInstance() failed: user credentials is nil")
            return false
        }
        
        self.deviceId = deviceId
        self.walletId = walletId
        
        do {
            try initializeFireblocksSDK()
            return true
        } catch {
            print("FireblocksManager, initInstance() throws exc: \(error).")
            return false
        }
    }
        
    func getSdkInstance() -> FireblocksSDK.Fireblocks? {
        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            print("FireblocksManager, getFireblocksInstance() can't get instance: \(error).")
            return nil
        }
    }
    
    func generateDeviceId() -> String {
        return Fireblocks.generateDeviceId()
    }
    
    func generateMpcKeys(_ delegate: FireblocksKeyCreationDelegate) async {
        do {
            let algorithms: Set<Algorithm> = Set([.MPC_ECDSA_SECP256K1])
            let result = try await getSdkInstance()?.generateMPCKeys(algorithms: algorithms)
            let isGenerated = result?.first?.description().contains("READY") ?? false
            await delegate.isKeysGenerated(isGenerated: isGenerated)
        } catch {
            print("FireblocksManager, generateMpcKeys() failed: \(error).")
        }
    }
    
    func signTransaction(transactionId: String) async -> Bool {
        do {
            let result = try await getSdkInstance()?.signTransaction(txId: transactionId)
            return result?.transactionSignatureStatus == .COMPLETED
        } catch {
            print("FireblocksManager, signTransaction() failed: \(error).")
            return false
        }
    }
    
    func getMpcKeys() -> [KeyDescriptor] {
        return getSdkInstance()?.getKeysStatus() ?? []
    }
    
    func getFullKey() async -> [String: Data]? {
        guard let instance = getSdkInstance() else {
            return nil
        }
        
        var keysSet: Set<String> = []
        for mpcKey in getMpcKeys() {
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
            print("FireblocksManager, Takeover() can't takeover keys: \(error).")
            return nil
        }
    }
    
    func recoverWallet(recoverKey: String) async -> Bool {
        guard let instance = getSdkInstance() else {
            return false
        }
        
        do {
            let keySet = try await instance.recoverKeys(passphrase: recoverKey)
            if keySet.isEmpty { return false }
            if keySet.first(where: {$0.keyRecoveryStatus == .ERROR}) != nil  { return false }
            return true
        } catch {
            print("FireblocksManager, recoverWallet() can't recover wallet: \(error).")
            return false
        }
    }
    
    func generatePassphrase() -> String {
        return Fireblocks.generateRandomPassPhrase()
    }
    
    func backupKeys(passphrase: String) async -> Set<FireblocksSDK.KeyBackup>? {
        guard let instance = getSdkInstance() else {
            return nil
        }
        
        do {
            return try await instance.backupKeys(passphrase: passphrase)
        } catch {
            print("FireblocksManager, backupKeys(): \(error).")
            return nil
        }
    }
    
    private func initializeFireblocksSDK() throws {
        if getSdkInstance() == nil {
            let _ = try Fireblocks.initialize(
                deviceId: deviceId,
                messageHandlerDelegate: self,
                keyStorageDelegate: KeyStorageProvider(deviceId: self.deviceId),
                fireblocksOptions: FireblocksOptions(env: .sandbox, eventHandlerDelegate: self)
            )
        }
        
        PollingManager.shared.createListener(deviceId: deviceId, instance: self, sessionManager: SessionManager.shared)
        
    }
    
    func stopPollingMessages() {
        PollingManager.shared.removeListener(deviceId: deviceId)
    }

    
    private func isAllKeysBackedUp(_ keyBackupSet: Set<FireblocksSDK.KeyBackup>) -> Bool {
        for status in keyBackupSet {
            if !status.description().contains("SUCCESS") {
                return false
            }
        }
        return true
    }
}

extension FireblocksManager: PollingListenerDelegate {
    func handleIncomingMessage(payload: String, messageId: Int?) {
        let instance = try? Fireblocks.getInstance(deviceId: deviceId)
        instance?.handleIncomingMessage(payload: payload, callback: { [weak self] success in
            if let self, let messageId {
                Task {
                    await SessionManager.shared.deleteMessage(deviceId: self.deviceId, messageId: "\(messageId)")
                }
            }
        })

    }
    
    func handleTransactions(transactions: [TransactionResponse]) {
        TransfersViewModel.shared.handleTransactions(transactions: transactions)
    }
    
    func lastUpdate() -> TimeInterval? {
        return TransfersViewModel.shared.lastUpdate()
    }
    
    func handleError(error: String?) {
        print(error ?? "")
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
    
    func handleIncomingMessage(data: [Any]) {
        for element in data {
            do {
                let instance = try Fireblocks.getInstance(deviceId: deviceId)
                if let payload = castByteArrayToString(element) {
                    instance.handleIncomingMessage(payload: payload) { messageHandled in
                        print("FireblocksManager, incoming message handled: \(messageHandled).")
                    }
                }
            } catch {
                print("FireblocksManager, handleIncomingMessage() throws exception: \(error).")
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
            print("FireblocksManager, status(.KeyCreation): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Backup(status, error):
            print("FireblocksManager, status(.Backup): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Recover(status, error):
            print("FireblocksManager, status(.Recover): \(String(describing: status?.description())). Error: \(String(describing: error)).")
            break
        case let .Transaction(status, error):
            print("FireblocksManager, status(.Transaction): \(status.description()). Error: \(String(describing: error)).")
            break
        @unknown default:
            print("FireblocksManager, @unknown case")
            break
        }
    }
}
