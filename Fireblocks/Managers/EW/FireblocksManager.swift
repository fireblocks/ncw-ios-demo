//
//  FireblocksManager.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/01/2025.
//

import FirebaseAuth
import Foundation
import OSLog
#if DEV
import FireblocksDev
import EmbeddedWalletSDKDev
#else
import FireblocksSDK
import EmbeddedWalletSDK
#endif

private let logger = Logger(subsystem: "Fireblocks", category: "FireblocksManager")

class FireblocksManager: FireblocksManagerProtocol, ObservableObject {
    var latestBackupDeviceId: String = ""
    
    func stopPollingMessages() {
        PollingManager.shared.stopPolling()
    }
    
    static let shared = FireblocksManager()
    private init(){}
    
    var deviceId: String = ""
    var walletId: String = ""
    var algoArray: [Algorithm] = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
    var didClearWallet = false
    
    var options: EmbeddedWalletOptions?
    var keyStorageDelegate: KeyStorageProvider?
    var ewManager = EWManager.shared

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

    func getInstance() throws -> EmbeddedWallet {
        return try ewManager.initialize()
    }
    
    func initializeCore() throws -> Fireblocks {
        guard !deviceId.isEmpty else {
            throw CustomError.deviceId
        }

        let ewInstance = try getInstance()

        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch {
            self.keyStorageDelegate = KeyStorageProvider(deviceId: deviceId)
            return try ewInstance.initializeCore(deviceId: deviceId, keyStorage: keyStorageDelegate!)
        }
    }

    func assignWallet() async throws {
        self.options = EmbeddedWalletOptions(env: .DEV9, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
        let instance = try getInstance()
        let result = try await instance.assignWallet()
        if let walletId = result.walletId {
            self.walletId = walletId
        } else {
            throw(CustomError.assignWallet)
        }
    }
    
    func getDevice() async -> Device? {
        guard !deviceId.isEmpty else {
            return nil
        }
        
        return try? await ewManager.getDevice(deviceId: deviceId)
    }
    
    func getLatestBackupState() async -> LatestBackupState  {
        guard let email = getUserEmail() else {
            return .error(CustomError.login)
        }
        
        do {
            let instance = try getInstance()
            if didClearWallet {
                UsersLocalStorageManager.shared.removeLastDeviceId(email: email)
            }
            
            if let deviceId = UsersLocalStorageManager.shared.lastDeviceId(email: email), !deviceId.isTrimmedEmpty {
                self.deviceId = deviceId
                AppLoggerManager.shared.loggers[deviceId] = AppLogger(deviceId: deviceId)
                self.latestBackupDeviceId = deviceId
                let _ = try initializeCore()
                return .exist
            }
            
            if let keys = try await instance.getLatestBackup().keys {
                if let latestBackupDeviceId = keys.first?.deviceId {
                    self.deviceId = generateDeviceId()
                    self.latestBackupDeviceId = latestBackupDeviceId
                    let _ = try initializeCore()
                    return .joinOrRecover
                } else {
                    return .error(CustomError.noWallet)
                }
            } else {
                return .error(CustomError.noWallet)
            }
        } catch let error as EmbeddedWalletException{
            if let httpStatusCode = error.httpStatusCode, httpStatusCode == 404 {
                self.deviceId = generateDeviceId()
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: self.deviceId, email: email)
                do {
                    let _ = try initializeCore()
                    return .generate
                } catch {
                    return .error(CustomError.genericError(error.localizedDescription))
                }
            }
            return .error(error)
        } catch {
            return .error(error)
        }
    }
        
    func startPolling() {
        Task {
            await PollingManager.shared.startPolling(accountId: 0, order: .DESC)
        }
    }

    func signOut() throws {
        try signOutFlow()
        ewManager.instance = nil
    }
}

//MARK - AuthTokenRetriever -
extension FireblocksManager: AuthTokenRetriever {
    func getAuthToken() async -> Result<String, any Error> {
        if let token = await AuthRepository.getUserIdToken() {
            return .success(token)
        } else {
            return .failure(CustomError.genericError("Failed to get user token"))
        }
    }
}

