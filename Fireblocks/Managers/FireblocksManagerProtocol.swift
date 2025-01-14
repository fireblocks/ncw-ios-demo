//
//  FireblocksManagerProtocol.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/01/2025.
//

import FirebaseAuth
import Foundation
import OSLog
import SwiftUI
import UIKit

#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

protocol FireblocksManagerProtocol {
    var algoArray: [Algorithm] { get set }
    var deviceId: String { get }
    var walletId: String { get }
    var errorMessage: String? { get }
    
    func generateDeviceId() -> String
    func generatePassphraseId() -> String
    func generatePassphrase() -> String
    func getURLForLogFiles() -> URL?
    
    func getDeviceId() -> String
    func getWalletId() -> String
    func generateMpcKeys() async -> Set<KeyDescriptor>?
    func generateECDSAKeys() async -> Set<KeyDescriptor>?
    func generateEDDSAKeys() async -> Set<KeyDescriptor>?
    func getNCWInstance() -> Fireblocks?
    func getMpcKeys() -> [KeyDescriptor]
    func getFullKey() async -> [String: Data]?
    func generateKeys() async -> Set<KeyDescriptor>?
    func isKeyInitialized(algorithm: Algorithm) -> Bool
    func isInstanceInitialized(authUser: AuthUser?) -> Bool
    func getUserEmail() -> String?
    func assignWallet() async -> String?
    
    func startPolling()
    func stopPollingMessages()
    func signTransaction(transactionId: String) async -> Bool
    func stopTransaction()
    
    func addDevice(joinWalletHandler: FireblocksJoinWalletHandler) async -> Bool
    func approveJoinWallet(requestId: String) async throws -> Set<JoinWalletDescriptor>
    func stopJoinWallet()
    
    
    func takeOver() async -> Set<FullKey>?
    func deriveAssetKey(privateKey: String, derivationParams: DerivationParams) async -> KeyData?
    
    func recoverWallet(resolver: FireblocksPassphraseResolver) async -> Bool
    func backupKeys(passphrase: String, passphraseId: String) async -> Set<KeyBackup>?
    func signOut()
    
}

extension FireblocksManagerProtocol {
    func generateDeviceId() -> String {
        let deviceId = Fireblocks.generateDeviceId()
        AppLoggerManager.shared.loggers[deviceId] = AppLogger(deviceId: deviceId)
        return deviceId
    }

    func generatePassphraseId() -> String {
        return Fireblocks.generatePassphraseId()
    }

    func generatePassphrase() -> String {
        return Fireblocks.generateRandomPassPhrase()
    }

    func getURLForLogFiles() -> URL? {
        return Fireblocks.getURLForLogFiles()
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
    
    func getUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }

    func getMpcKeys() -> [KeyDescriptor] {
        return getNCWInstance()?.getKeysStatus() ?? []
    }

    func getFullKey() async -> [String: Data]? {
        guard getNCWInstance() != nil else {
            return nil
        }
        
        var keysSet: Set<String> = []
        let allKeys = getMpcKeys()
        for mpcKey in allKeys {
            keysSet.insert(mpcKey.keyId ?? "")
        }
            
        return nil
    }

    func generateKeys() async -> Set<KeyDescriptor>? {
        do {
            let algorithms: Set<Algorithm> = Set(algoArray)
            let startDate = Date()
            let result = try await getNCWInstance()?.generateMPCKeys(algorithms: algorithms)
            print("Measure - generateMpcKeys \(Date().timeIntervalSince(startDate))")
            return result
        } catch {
            AppLoggerManager.shared.logger()?.log("FireblocksManager, generateMpcKeys() failed: \(error).")
            return nil
        }
    }
    
    func startPolling() {}
    
    func backupKeys(passphrase: String, passphraseId: String) async -> Set<KeyBackup>? {
        guard let instance = getNCWInstance() else {
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
    
    func stopJoinWallet() {
        getNCWInstance()?.stopJoinWallet()
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
