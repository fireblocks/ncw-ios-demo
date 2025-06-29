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
    // Property to store the push notification device token in memory
    private var pendingDeviceToken: String?
    /**
     * Transaction update mechanism configuration:
     * - true: Uses polling to check for transaction updates (current default for demo)
     * - false: Uses push notifications for real-time updates (recommended for production)
     * 
     * Push notifications require:
     * 1. Fireblocks minimal backend server setup
     * 2. Webhook configuration in Fireblocks Console
     * 3. Firebase Cloud Messaging (FCM) configuration
     * 4. APNs certificate setup (see AppDelegate.swift for complete implementation)
     * 
     * Set to false for production apps to get real-time updates with better battery efficiency.
     */
    private var useTransactionPolling: Bool = true
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
        algoArray = [.MPC_EDDSA_ED25519]
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
        self.options = EmbeddedWalletOptions(env: EnvironmentConstants.ewEnv, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
        let instance = try getInstance()
        let result = try await instance.assignWallet()
        if let walletId = result.walletId {
            self.walletId = walletId
            await registerPushNotificationToken()
        } else {
            throw(CustomError.assignWallet)
        }
    }
    
    func registerPushNotificationToken() async {
        if let token = pendingDeviceToken, !walletId.isEmpty, !deviceId.isEmpty {
            do {
                try await registerPushNotificationToken(token)
            } catch {
                logger.error("Failed to register pending token: \(error)")
            }
        }
    }
    
    func registerPushNotificationToken(_ token: String) async throws {
        guard !walletId.isEmpty else {
            logger.error("Cannot register push token: Wallet ID is empty")
            pendingDeviceToken = token // Store token for later
            throw CustomError.genericError("Wallet ID is empty")
        }
        
        guard !deviceId.isEmpty else {
            logger.error("Cannot register push token: Device ID is empty")
            pendingDeviceToken = token // Store token for later
            throw CustomError.genericError("Device ID is empty")
        }
        
        logger.info("Registering device token for walletId: \(self.walletId)")
        
        let result = try await SessionManager.shared.registerToken(
            body: RegisterTokenBody(token: token, walletId: walletId, deviceId: deviceId)
        )
        
        if result.success == true {
            logger.info("Successfully registered push notification token")
            // Clear pending token after successful registration
            pendingDeviceToken = nil
        } else {
            logger.error("Failed to register push notification token")
            throw CustomError.genericError("Failed to register push notification token")
        }
    }
    
    func handleNotificationPayload(userInfo: [AnyHashable: Any]) async {
        // Extract txId from the notification payload
        guard let txId = userInfo["txId"] as? String, !txId.isEmpty else {
            logger.error("No valid txId found in notification payload")
            return
        }

        logger.info("Handling notification with txId: \(txId)")

        guard !walletId.isEmpty, !deviceId.isEmpty else {
            logger.error("Cannot handle notification: Wallet ID or Device ID is empty")
            return
        }
    
        PollingManager.shared.getTransactionById(txId: txId)
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
                self.latestBackupDeviceId = self.deviceId

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
            if (useTransactionPolling) {
                await PollingManager.shared.startPolling(accountId: 0, order: .DESC)
            } else {
                await PollingManager.shared.fetchTransactions(accountId: 0, order: .DESC)
            }
        }
    }
    
    func appWillEnterForeground() {
        logger.info("App entering foreground, fetching latest transactions")
        
        // Only fetch transactions if we have wallet and device IDs
        if !walletId.isEmpty && !deviceId.isEmpty {
            Task {
                await PollingManager.shared.fetchTransactions(accountId: 0, order: .DESC)
            }
        } else {
            logger.warning("Cannot fetch transactions: Wallet ID or Device ID is empty")
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

