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
    func isInstanceInitialized(authUser: AuthUser?) -> Bool {
        return false
    }
    
    func stopPollingMessages() {
        
    }
    
    func signTransaction(transactionId: String) async -> Bool {
        return false
    }
    
    func stopTransaction() {
        
    }
    
    func approveJoinWallet(requestId: String) async throws -> Set<FireblocksDev.JoinWalletDescriptor> {
        return Set()
    }
    
    func takeOver() async -> Set<FireblocksDev.FullKey>? {
        return nil
    }
    
    func deriveAssetKey(privateKey: String, derivationParams: FireblocksDev.DerivationParams) async -> FireblocksDev.KeyData? {
        return nil
    }
    
    func recoverWallet(resolver: any FireblocksDev.FireblocksPassphraseResolver) async -> Bool {
        return false
    }
        
    static let shared = FireblocksManager()
        
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
    
    func addDevice(joinWalletHandler: FireblocksJoinWalletHandler) async -> Bool {
        return true
    }

    func getInstance() -> EmbeddedWallet? {
        guard let authClientId else {
            errorMessage = "Unknown authClientId"
            return nil
        }

        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return instance
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func initializeCore() -> Fireblocks? {
        guard !deviceId.isEmpty else {
            errorMessage = "Unknown Device Id"
            return nil
        }
        
        self.keyStorageDelegate = KeyStorageProvider(deviceId: deviceId)
        if let keyStorageDelegate {
            guard let instance = getInstance() else { return nil }
            do {
                return try instance.initializeCore(deviceId: deviceId, keyStorage: keyStorageDelegate)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
            
        return nil

    }

    func assignWallet() async -> String? {
        self.authClientId = "6303105e-38ac-4a21-8909-2b1f7f205fd1"
        self.options = EmbeddedWalletOptions(env: .RENTBLOCKS, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
        guard let instance = getInstance() else { return nil }

        do {
            let result = await instance.assignWallet()
            if let walletId = try result.get().walletId {
                self.walletId = walletId
                return walletId
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        return nil
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
                return initializeCore() == nil ? .error : .exist
            }
            
            if let keys = try await instance.getLatestBackup().get().keys {
                if let _ = keys.first?.deviceId {
                    self.deviceId = generateDeviceId()
                    return initializeCore() == nil ? .error : .joinOrRecover
                } else {
                    errorMessage = "Couldn't sign in. There is no existing wallet"
                }
            } else {
                errorMessage = "Couldn't sign in. There is no existing wallet"
            }
        } catch {
            if error.code == 404 {
                self.deviceId = generateDeviceId()
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: self.deviceId, email: email)
                return initializeCore() == nil ? .error : .generate
            }
            errorMessage = error.localizedDescription
        }
        return .error
    }
}

//MARK - AuthTokenRetriever -
extension FireblocksManager: AuthTokenRetriever {
    func getAuthToken() async -> Result<String, any Error> {
        let token = await AuthRepository.getUserIdToken()
        return .success(token)
    }
}

