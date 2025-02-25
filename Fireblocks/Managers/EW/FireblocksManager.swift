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
    
//    func isInstanceInitialized(authUser: AuthUser?) -> Bool {
//        return false
//    }
    
    func stopPollingMessages() {
        PollingManager.shared.stopPolling()
    }
    
    static let shared = FireblocksManager()
    private init(){}
    
    var deviceId: String = ""
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
    
//    var authClientId = "6303105e-38ac-4a21-8909-2b1f7f205fd1"
//    let options = EmbeddedWalletOptions(env: .RENTBLOCKS, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
    var authClientId: String?
    var options: EmbeddedWalletOptions?
    var keyStorageDelegate: KeyStorageProvider?
    var ewManager = EWManager.shared

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

    func initializeFireblocksSDK() throws {
        if getNCWInstance() == nil {
            let _ = initializeCore()
        }
    }
    
    func getNCWInstance() -> Fireblocks? {
        guard !deviceId.isEmpty else {
            errorMessage = "Unknown Device Id"
            return nil
        }

        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch let error as FireblocksError {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }

        return nil
    }
    
    func getInstance() -> EmbeddedWallet? {
        guard let authClientId else {
            errorMessage = "Unknown authClientId"
            return nil
        }

        return ewManager.initialize()
    }
    
    func initializeCore() -> Fireblocks? {
        guard !deviceId.isEmpty else {
            errorMessage = "Unknown Device Id"
            return nil
        }
        
        self.keyStorageDelegate = KeyStorageProvider(deviceId: deviceId)
        if let keyStorageDelegate {
            guard let instance = getInstance() else { return nil }
            if let ncwInstance = getNCWInstance() {
                return ncwInstance
            }

            do {
                return try instance.initializeCore(deviceId: deviceId, keyStorage: keyStorageDelegate)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
            
        return nil

    }

    func assignWallet() async -> String? {
        self.authClientId = "1fcfe7cf-60b4-4111-b844-af607455ff76"
        self.options = EmbeddedWalletOptions(env: .DEV9, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
        guard let instance = getInstance() else { return nil }

        do {
            let result = try await instance.assignWallet()
            if let walletId = result.walletId {
                self.walletId = walletId
                return walletId
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
    }
    
    func getDevice() async -> Device? {
        guard !deviceId.isEmpty else {
            errorMessage = "Failed to get device. deviceId is empty"
            return nil
        }
        
        return await ewManager.getDevice(deviceId: deviceId)
    }
    
    func getLatestBackupState() async -> LatestBackupState  {
        guard let instance = getInstance() else { return .error }
        guard let email = getUserEmail() else {
            errorMessage = "Failed to login. there is no signed in user"
            return .error
        }
        
        do {
            if let deviceId = UsersLocalStorageManager.shared.lastDeviceId(email: email), !deviceId.isTrimmedEmpty {
                self.deviceId = deviceId
                AppLoggerManager.shared.loggers[deviceId] = AppLogger(deviceId: deviceId)
                self.latestBackupDeviceId = deviceId
                return initializeCore() == nil ? .error : .exist
            }
            
            if let keys = try await instance.getLatestBackup().keys {
                if let latestBackupDeviceId = keys.first?.deviceId {
                    self.deviceId = generateDeviceId()
                    self.latestBackupDeviceId = latestBackupDeviceId
                    return initializeCore() == nil ? .error : .joinOrRecover
                } else {
                    errorMessage = "Couldn't sign in. There is no existing wallet"
                }
            } else {
                errorMessage = "Couldn't sign in. There is no existing wallet"
            }
        } catch let error as EmbeddedWalletException{
            if let httpStatusCode = error.httpStatusCode, httpStatusCode == 404 {
                self.deviceId = generateDeviceId()
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: self.deviceId, email: email)
                return initializeCore() == nil ? .error : .generate
            }
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        return .error
    }
        
    func startPolling() {
        Task {
            await PollingManager.shared.startPolling(accountId: 0, order: .DESC)
        }
    }

    func signOut() {
        do{
            try Auth.auth().signOut()
            stopPollingMessages()
            TransfersViewModel.shared.signOut()
            AssetListViewModel.shared.signOut()
            stopJoinWallet()
            UsersLocalStorageManager.shared.resetAuthProvider()
            deviceId = ""
            walletId = ""
            latestBackupDeviceId = ""
            ewManager.instance = nil
            SignInViewModel.shared.launchView = nil
        } catch{
            print("Can't sign out with current user: \(error.localizedDescription)")
            return
        }

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

