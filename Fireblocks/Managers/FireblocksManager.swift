//
//  FireblocksManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 10/07/2023.
//

import FirebaseAuth
import Foundation
import OSLog
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

private let logger = Logger(subsystem: "Fireblocks", category: "FireblocksManager")
protocol FireblocksKeyCreationDelegate {
    func isKeysGenerated(isGenerated: Bool, didJoin: Bool, error: String?)
}

class FireblocksManager {
    
    static let shared = FireblocksManager()
    
    private var deviceId: String = ""
    private var walletId: String = ""
    private var algoArray: [Algorithm] = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
//    private var algoArray: [Algorithm] = [.MPC_EDDSA_ED25519]
    private var broadcast_counter: [String: Int] = [:]
    private var sendMPC_counter = 0
    private var didTimeout = 0

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
            AppLoggerManager.shared.logger()?.log("FireblocksManager, initInstance() failed: user credentials is nil")
            return false
        }
        
        self.deviceId = deviceId
        self.walletId = walletId
        
        do {
            try initializeFireblocksSDK()
            return true
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, initInstance() throws exc: \(error).")
            return false
        }
    }
        
    func getSdkInstance() -> Fireblocks? {
        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, getFireblocksInstance() can't get instance: \(error).")
            return nil
        }
    }
    
    func generateDeviceId() -> String {
        return Fireblocks.generateDeviceId()
    }
    
    func generatePassphraseId() -> String {
        return Fireblocks.generatePassphraseId()
    }
    
    func getURLForLogFiles() -> URL? {
        return Fireblocks.getURLForLogFiles()
    }
    
    /*By default, workspaces are not enabled with EdDSA so you may remove MPC_EDDSA_ED25519 when calling generateMPCKeys
    Please ask your CSM or in the https://community.fireblocks.com/ to enable your workspace to support EdDSA if you wish to work with EdDSA chains.
     */
    func generateMpcKeys(_ delegate: FireblocksKeyCreationDelegate) async {
        algoArray = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
        await generateKeys(delegate)
    }
    
    func generateECDSAKeys(_ delegate: FireblocksKeyCreationDelegate) async {
        algoArray = [.MPC_ECDSA_SECP256K1]
        await generateKeys(delegate)
    }

    func generateEDDSAKeys(_ delegate: FireblocksKeyCreationDelegate) async {
        algoArray = [.MPC_EDDSA_ED25519]
        await generateKeys(delegate)
    }

    private func generateKeys(_ delegate: FireblocksKeyCreationDelegate) async {
        do {
            let algorithms: Set<Algorithm> = Set(algoArray)
            let startDate = Date()
            let result = try await getSdkInstance()?.generateMPCKeys(algorithms: algorithms)
            print("Measure - generateMpcKeys \(Date().timeIntervalSince(startDate))")
            let isGenerated = result != nil && result!.filter({$0.keyStatus == .READY}).count > 0
            AppLoggerManager.shared.logger()?.log("FireblocksManager, generateMpcKeys() isGenerated value: \(isGenerated).")

            if isGenerated {
                //We simulate a simple way to implement a Polling mechanism.
                //During the integration it is ineeded to generate a mechanism for fetching and listening to incoming messages and transactions, which could be any implementation (e.g. polling, web-socket, push etc.)
                startPolling()
            }
            
            delegate.isKeysGenerated(isGenerated: isGenerated, didJoin: false, error: nil)
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, generateMpcKeys() failed: \(error).")
        }
    }

    func startPolling() {
        PollingManager.shared.createListener(deviceId: deviceId, instance: self, sessionManager: SessionManager.shared)
    }
    
    func signTransaction(transactionId: String) async -> Bool {
        do {
            let startDate = Date()
            let result = try await getSdkInstance()?.signTransaction(txId: transactionId)
            print("Measure - signTransaction \(Date().timeIntervalSince(startDate))")
            print("RESULT: \(result?.transactionSignatureStatus.rawValue ?? "")")
            return result?.transactionSignatureStatus == .COMPLETED
        } catch let err as FireblocksError {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, signTransaction() failed: \(err.description).")
            return false
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, signTransaction() failed: \(error.localizedDescription).")
            return false
        }
    }
    
    func stopTransaction() {
        getSdkInstance()?.stopSignTransaction()
    }
    

    func addDevice(_ delegate: FireblocksKeyCreationDelegate, joinWalletHandler: FireblocksJoinWalletHandler) async {
        do {
            let startDate = Date()
            guard let result = try await getSdkInstance()?.requestJoinExistingWallet(joinWalletHandler: joinWalletHandler) else {
                delegate.isKeysGenerated(isGenerated: false, didJoin: true, error: nil)
                return
            }
            print("Measure - addDevice \(Date().timeIntervalSince(startDate))")

            let didFail = result.filter({$0.keyStatus != .READY}).count > 0
            if !didFail {
                startPolling()
            }
            delegate.isKeysGenerated(isGenerated: !didFail, didJoin: true, error: nil)
        } catch let err as FireblocksError {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, addDevice() failed: \(err.description).")
            delegate.isKeysGenerated(isGenerated: false, didJoin: false, error: err.description)
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, addDevice() failed: \(error.localizedDescription).")
            delegate.isKeysGenerated(isGenerated: false, didJoin: false, error: error.localizedDescription)
        }
    }
    
    func approveJoinWallet(requestId: String) async throws -> Set<JoinWalletDescriptor> {
        let instance = try Fireblocks.getInstance(deviceId: deviceId)
        return try await instance.approveJoinWalletRequest(requestId: requestId)
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
            keysSet.insert(mpcKey.keyId ?? "")
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
            AppLoggerManager.shared.logger()?.log("FireblocksManager, Takeover() can't takeover keys: \(error).")
            return nil
        }
    }
    
    func deriveAssetKey(privateKey: String, derivationParams: DerivationParams) async -> KeyData? {
        guard let instance = getSdkInstance() else {
            return nil
        }
        
        do {
            return try await instance.deriveAssetKey(extendedPrivateKey: privateKey, bip44DerivationParams: derivationParams)
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, deriveAssetKey failed: \(error).")
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
            startPolling()
            return true
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, recoverWallet() can't recover wallet: \(error).")
            return false
        }
    }
    
    func generatePassphrase() -> String {
        return Fireblocks.generateRandomPassPhrase()
    }
    
    func backupKeys(passphrase: String, passphraseId: String) async -> Set<KeyBackup>? {
        guard let instance = getSdkInstance() else {
            return nil
        }
        
        do {
            let keys = try await instance.backupKeys(passphrase: passphrase, passphraseId: passphraseId)
            return keys
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, backupKeys(): \(error).")
            return nil
        }
    }
    
    private func initializeFireblocksSDK() throws {
        if getSdkInstance() == nil {
            let _ = try Fireblocks.initialize(
                deviceId: deviceId,
                messageHandlerDelegate: self,
                keyStorageDelegate: KeyStorageProvider(deviceId: self.deviceId),
                fireblocksOptions: FireblocksOptions(env: EnvironmentConstants.env, eventHandlerDelegate: self, logLevel: .info, logToConsole: true, reporting: ReportingOptions(enabled: true))
            )
        }
    }
    
    func stopPollingMessages() {
        PollingManager.shared.removeListener(deviceId: deviceId)
    }

    func stopJoinWallet() {
        getSdkInstance()?.stopJoinWallet()
    }
    
    private func isAllKeysBackedUp(_ keyBackupSet: Set<KeyBackup>) -> Bool {
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
        AppLoggerManager.shared.logger()?.log("\(error ?? "")")
    }
    
    
}

extension FireblocksManager: MessageHandlerDelegate {
    func handleOutgoingMessage(payload: String, response: @escaping (String?) -> (), error: @escaping (String?) -> ()) {

//  **** SIMULATE TIMEOUT ****
//        print("broadcast_counter: \(broadcast_counter)")
//        if payload.contains("broadcast_mpc_msg") {
//            let arr1 = payload.components(separatedBy: "transaction")
//            if arr1.count > 1 {
//                let arr2 = arr1[1].components(separatedBy: "\"")
//                if arr2.count > 2 {
//                    let keyId = arr2[2]
//                    print("TRANSACTION RETRY \(keyId)")
//                    if !keyId.isEmpty {
//                        var counter = broadcast_counter[keyId] ?? 0
//                        if  counter < 3 {
//                            broadcast_counter[keyId] = counter + 1
//                            response("TEST RETRY")
//                            return
//                        }
//                    }
//                }
//            }
//        }
//        
//        if payload.contains("send_mpc_public_keys") {
//            if sendMPC_counter < 3 {
//                sendMPC_counter += 1
//                error("TEST ERROR")
//                return
//            }
//        }
//
//        if didTimeout == 0, payload.contains("PROOF") {
//            didTimeout += 1
//            Task {
//                do {
//                    let res = try? await SessionManager.shared.rpc(
//                        deviceId: deviceId,
//                        message: payload
//                    )
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
//                        response(res)
//                    }
//                } catch let err {
//                    error(err.localizedDescription)
//                }
//            }
//        } else {
//            didTimeout = 0
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

//        }
        
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
    func onEvent(event: FireblocksEvent) {
        switch event {
        case let .KeyCreation(status, error):
            AppLoggerManager.shared.logger()?.log("FireblocksManager, status(.KeyCreation): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Backup(status, error):
            AppLoggerManager.shared.logger()?.log("FireblocksManager, status(.Backup): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Recover(status, error):
            AppLoggerManager.shared.logger()?.log("FireblocksManager, status(.Recover): \(String(describing: status?.description())). Error: \(String(describing: error)).")
            break
        case let .Transaction(status, error):
            AppLoggerManager.shared.logger()?.log("FireblocksManager, status(.Transaction): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .Takeover(status, error):
            AppLoggerManager.shared.logger()?.log("FireblocksManager, status(.Takeover): \(status.description()). Error: \(String(describing: error)).")
            break
        case let .JoinWallet(status, error):
            AppLoggerManager.shared.logger()?.log("FireblocksManager, status(.JoinWallet): \(status.description()). Error: \(String(describing: error)).")
            break
        @unknown default:
            AppLoggerManager.shared.logger()?.log("FireblocksManager, @unknown case")
            break
        }
    }
}
