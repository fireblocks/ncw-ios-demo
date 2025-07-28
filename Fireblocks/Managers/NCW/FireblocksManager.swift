//
//  FireblocksManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 10/07/2023.
//

import FirebaseAuth
import Foundation
import OSLog
import UIKit
import SwiftUI

#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

private let logger = Logger(subsystem: "Fireblocks", category: "FireblocksManager")

class FireblocksManager: BaseFireblocksManager, FireblocksManagerProtocol {
    static let shared = FireblocksManager()
    
    // MARK: - FireblocksManagerProtocol Properties
    var deviceId: String = ""
    var latestBackupDeviceId: String = ""
    var walletId: String = ""
    var algoArray: [Algorithm] = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
    var didClearWallet = false
    
    var errorMessage: String? {
        didSet {
            if errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.errorMessage = nil
                }
            }
        }
    }

    private var broadcast_counter: [String: Int] = [:]
    private var sendMPC_counter = 0
    private var didTimeout = 0

    private override init() {
        super.init()
    }
        
    func getNCWInstance() -> Fireblocks? {
        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            AppLoggerManager.shared.logger()?.error("FireblocksManager, getFireblocksInstance() can't get instance: \(error).")
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func initializeCore() throws -> Fireblocks {
        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            return try Fireblocks.initialize(
                deviceId: deviceId,
                messageHandlerDelegate: self,
                keyStorageDelegate: KeyStorageProvider(deviceId: self.deviceId),
                fireblocksOptions: FireblocksOptions(env: EnvironmentConstants.env, eventHandlerDelegate: createEventHandlerDelegate(), logLevel: .info, logToConsole: true, reporting: ReportingOptions(enabled: true))
            )
        }
    }

    
    func assignWallet() async throws {
        let result = try await SessionManager.shared.assign(deviceId:deviceId)
        if let walletId = result.walletId {
            self.walletId = walletId
        } else {
            throw(CustomError.assignWallet)
        }
    }
    
    func getLatestBackupState() async -> LatestBackupState  {
        guard let email = getUserEmail() else {
            return .error(CustomError.login)
        }
        
        do {
            if didClearWallet {
                self.deviceId = generateDeviceId()
                self.latestBackupDeviceId = deviceId
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: self.deviceId, email: email)
                let _ = try initializeCore()
                return .generate
            }
            
            if let deviceId = UsersLocalStorageManager.shared.lastDeviceId(email: email), !deviceId.isTrimmedEmpty {
                self.deviceId = deviceId
                self.latestBackupDeviceId = deviceId
                let _ = try initializeCore()
                return .exist
            }
            
            let devices = try await SessionManager.shared.getDevices()
            let device = devices?.devices.last
            
            if device == nil || device!.deviceId.isEmptyOrNil || device!.walletId.isEmptyOrNil {
                self.deviceId = generateDeviceId()
                self.latestBackupDeviceId = deviceId
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: self.deviceId, email: email)
                let _ = try initializeCore()
                return .generate
            } else {
                self.walletId = device?.walletId ?? ""
                let info = try await SessionManager.shared.getLatestBackupInfo(walletId: walletId)
                if info.deviceId.isEmptyOrNil {
                    return .error(CustomError.noAvailableBackup)
                } else {
                    self.deviceId = info.deviceId!
                    self.latestBackupDeviceId = info.deviceId!
                    return .joinOrRecover
                }
            }
        } catch {
            return .error(CustomError.genericError(error.localizedDescription))
        }
    }

    /*By default, workspaces are not enabled with EdDSA so you may remove MPC_EDDSA_ED25519 when calling generateMPCKeys
    Please ask your CSM or in the https://community.fireblocks.com/ to enable your workspace to support EdDSA if you wish to work with EdDSA chains.
     */
    func generateMpcKeys() async throws -> Set<KeyDescriptor> {
        algoArray = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
        return try await generateKeys()
    }
    
    func generateECDSAKeys() async throws -> Set<KeyDescriptor> {
        algoArray = [.MPC_ECDSA_SECP256K1]
        return try await generateKeys()
    }
    
    func generateEDDSAKeys() async throws -> Set<KeyDescriptor> {
        algoArray = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
        return try await generateKeys()
    }

    func startPolling() {
        PollingManager.shared.createListener(deviceId: deviceId, instance: self, sessionManager: SessionManager.shared)
    }
                    
    func stopPollingMessages() {
        PollingManager.shared.removeListener(deviceId: deviceId)
    }
    
    func fetchTransactions() {
    }

}

extension FireblocksManager: PollingListenerDelegate {
    func handleTransactions(transactions: [TransactionResponse]) {
        DispatchQueue.main.async {
            TransfersViewModel.shared.handleTransactions(transactions: transactions)
        }
    }
    
    func lastUpdate() -> TimeInterval? {
        return TransfersViewModel.shared.lastUpdate()
    }
    
    func handleError(error: String?) {
        AppLoggerManager.shared.logger()?.error("\(error ?? "")")
    }
    
    func signOut() throws {
        try signOutFlow()
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

