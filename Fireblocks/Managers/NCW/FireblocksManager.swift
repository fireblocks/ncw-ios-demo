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

class FireblocksManager: FireblocksManagerProtocol, ObservableObject {
    static let shared = FireblocksManager()
    
    var deviceId: String = ""
    var latestBackupDeviceId: String = ""
    var walletId: String = ""
    var algoArray: [Algorithm] = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
    
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

    private init() {
    }
        

//    func isInstanceInitialized(authUser: AuthUser?) -> Bool {
//        guard let deviceId = authUser?.deviceId,
//              let walletId = authUser?.walletId
//        else {
//            AppLoggerManager.shared.logger()?.log("FireblocksManager, initInstance() failed: user credentials is nil")
//            return false
//        }
//        
//        self.deviceId = deviceId
//        self.walletId = walletId
//        
//        do {
//            try initializeFireblocksSDK()
//            return true
//        } catch {
//            AppLoggerManager.shared.logger()?.log("FireblocksManager, initInstance() throws exc: \(error).")
//            return false
//        }
//    }
        
    func getNCWInstance() -> Fireblocks? {
        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, getFireblocksInstance() can't get instance: \(error).")
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func assignWallet() async -> String? {
        do {
            let result = try await SessionManager.shared.assign(deviceId:deviceId)
            if let walletId = result.walletId {
                self.walletId = walletId
                return walletId
            } else {
                errorMessage = "Failed to create wallet"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        return nil

    }
    
    func getLatestBackupState() async -> LatestBackupState  {
        guard let email = getUserEmail() else {
            errorMessage = "Failed to login. there is no signed in user"
            return .error
        }
        
        do {
            if let deviceId = UsersLocalStorageManager.shared.lastDeviceId(email: email), !deviceId.isTrimmedEmpty {
                self.deviceId = deviceId
                AppLoggerManager.shared.loggers[deviceId] = AppLogger(deviceId: deviceId)
                try initializeFireblocksSDK()
                return .exist
            }
            
            let devices = try await SessionManager.shared.getDevices()
            let device = devices?.devices.last
            if device == nil || device!.deviceId.isEmptyOrNil || device!.walletId.isEmptyOrNil {
                self.deviceId = generateDeviceId()
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: self.deviceId, email: email)
                try initializeFireblocksSDK()
                return .generate
            } else {
                self.walletId = device?.walletId ?? ""
                let info = try await SessionManager.shared.getLatestBackupInfo(walletId: walletId)
                if info.deviceId.isEmptyOrNil {
                    errorMessage = "No available backup"
                    return .error
                } else {
                    self.deviceId = info.deviceId!
                    AppLoggerManager.shared.loggers[deviceId] = AppLogger(deviceId: deviceId)
                    self.latestBackupDeviceId = info.deviceId!
                    return .joinOrRecover

                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        return .error
    }

    /*By default, workspaces are not enabled with EdDSA so you may remove MPC_EDDSA_ED25519 when calling generateMPCKeys
    Please ask your CSM or in the https://community.fireblocks.com/ to enable your workspace to support EdDSA if you wish to work with EdDSA chains.
     */
    func generateMpcKeys() async -> Set<KeyDescriptor>? {
        algoArray = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
        return await generateKeys()
    }
    
    func generateECDSAKeys() async -> Set<KeyDescriptor>? {
        algoArray = [.MPC_ECDSA_SECP256K1]
        return await generateKeys()
    }
    
    func generateEDDSAKeys() async -> Set<KeyDescriptor>? {
        algoArray = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
        return await generateKeys()
    }

    func startPolling() {
        PollingManager.shared.createListener(deviceId: deviceId, instance: self, sessionManager: SessionManager.shared)
    }
                
    func initializeFireblocksSDK() throws {
        if getNCWInstance() == nil {
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
    
    func signOut() {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return
        }

        do{
            try Auth.auth().signOut()
            FireblocksManager.shared.stopPollingMessages()
            TransfersViewModel.shared.signOut()
            AssetListViewModel.shared.signOut()
            FireblocksManager.shared.stopPollingMessages()
            FireblocksManager.shared.stopJoinWallet()
            UsersLocalStorageManager.shared.resetAuthProvider()
        } catch{
            print("Can't sign out with current user: \(error.localizedDescription)")
            return
        }
        
        let viewModel = LaunchView.ViewModel()
        let rootViewController = UIHostingController(
            rootView: NavigationContainerView() {
                LaunchView(viewModel: viewModel)
            }
        )
        window.rootViewController = rootViewController

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
