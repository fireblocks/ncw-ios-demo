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

class FireblocksManager: BaseFireblocksManager, FireblocksManagerProtocol {
    
    func stopPollingMessages() {
        PollingManager.shared.stopPolling()
    }
    
    static let shared = FireblocksManager()
    private override init(){
        super.init()
    }
    
    // MARK: - FireblocksManagerProtocol Properties
    var deviceId: String = ""
    var walletId: String = ""
    var latestBackupDeviceId: String = ""
    var algoArray: [Algorithm] = [.MPC_ECDSA_SECP256K1, .MPC_EDDSA_ED25519]
    var didClearWallet = false
    // Property to store the push notification device token in memory
    private var pendingDeviceToken: String?
    /**
     * Transaction update mechanism configuration:
     * - true: Uses polling to check for transaction updates (fallback option)
     * - false: Uses push notifications for real-time updates (default - recommended)
     * 
     * Push notifications require:
     * 1. Fireblocks minimal backend server setup (see: https://github.com/fireblocks/ew-backend-demo)
     * 2. Webhook configuration in Fireblocks Console
     * 3. Firebase Cloud Messaging (FCM) configuration
     * 4. APNs certificate setup (see AppDelegate.swift for complete implementation)
     * 
     * Set to true only if you need to use polling instead of push notifications.
     */
    private var useTransactionPolling: Bool = false
    
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
            let coreOptions = CoreOptions(eventHandlerDelegate: createEventHandlerDelegate())
            return try ewInstance.initializeCore(deviceId: deviceId, keyStorage: keyStorageDelegate!, coreOptions: coreOptions)
        }
    }

    func assignWallet() async throws {
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
                AppLoggerManager.shared.logger()?.error("Failed to register pending token: \(error)")
            }
        }
    }
    
    func registerPushNotificationToken(_ token: String) async throws {
        guard !walletId.isEmpty else {
            AppLoggerManager.shared.logger()?.error("Cannot register push token: Wallet ID is empty")
            pendingDeviceToken = token // Store token for later
            throw CustomError.genericError("Wallet ID is empty")
        }
        
        guard !deviceId.isEmpty else {
            AppLoggerManager.shared.logger()?.error("Cannot register push token: Device ID is empty")
            pendingDeviceToken = token // Store token for later
            throw CustomError.genericError("Device ID is empty")
        }
        
        AppLoggerManager.shared.logger()?.log("Registering device token for walletId: \(self.walletId)")

        
        let result = try await SessionManager.shared.registerToken(
            body: RegisterTokenBody(token: token, walletId: walletId, deviceId: deviceId)
        )
        
        if result.success == true {
            AppLoggerManager.shared.logger()?.log("registerToken finished successfully for walletId: \(self.walletId)")
            // Clear pending token after successful registration
            pendingDeviceToken = nil
        } else {
            AppLoggerManager.shared.logger()?.error("Failed to register push notification token")
            throw CustomError.genericError("Failed to register push notification token")
        }
    }
    
    func handleNotificationPayload(userInfo: [AnyHashable: Any]) async {
        // Extract txId from the notification payload
        guard let txId = userInfo["txId"] as? String, !txId.isEmpty else {
            AppLoggerManager.shared.logger()?.error("No valid txId found in notification payload")
            return
        }
        
        // get status from userInfo if available and log it with the tx id
        if let status = userInfo["status"] as? String {
            AppLoggerManager.shared.logger()?.log("Notification data: txId: \(txId), status: \(status)")
        } else {
            AppLoggerManager.shared.logger()?.log("Notification data: txId: \(txId), no status provided")
        }

        guard !walletId.isEmpty, !deviceId.isEmpty else {
            AppLoggerManager.shared.logger()?.error("Cannot handle notification: Wallet ID or Device ID is empty")
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
        fetchTransactions()
    }
    
    func fetchTransactions() {
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

