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
    var latestBackupDeviceId: String { get }
    var didClearWallet: Bool { get set }

    func generateDeviceId() -> String
    func generatePassphraseId() -> String
    func generatePassphrase() -> String
    func getURLForLogFiles() -> URL?
    
    func getDeviceId() -> String
    func getWalletId() -> String
    func generateMpcKeys() async throws -> Set<KeyDescriptor>
    func generateECDSAKeys() async throws -> Set<KeyDescriptor>
    func generateEDDSAKeys() async throws -> Set<KeyDescriptor>
    func initializeCore() throws -> Fireblocks
    func getMpcKeys() throws -> [KeyDescriptor]
    func generateKeys() async throws -> Set<KeyDescriptor>
    func isKeyInitialized(algorithm: Algorithm) throws -> Bool

    func getUserEmail() -> String?
    func assignWallet() async throws
    
    func startPolling()
    func stopPollingMessages()
    func signTransaction(transactionId: String) async throws -> Bool
    func stopTransaction() throws
    
    func addDevice(joinWalletHandler: FireblocksJoinWalletHandler) async throws -> Bool
    func approveJoinWallet(requestId: String) async throws -> Set<JoinWalletDescriptor>
    func stopJoinWallet() throws
    
    
    func takeOver() async throws -> Set<FullKey>
    func deriveAssetKey(privateKey: String, derivationParams: DerivationParams) async throws -> KeyData
    
    func recoverWallet(resolver: FireblocksPassphraseResolver) async throws -> Bool
    func backupKeys(passphrase: String, passphraseId: String) async throws -> Set<KeyBackup>
    func signOut() throws
    
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

    func isKeyInitialized(algorithm: Algorithm) throws -> Bool {
        return try getMpcKeys().filter({$0.algorithm == algorithm}).first?.keyStatus == .READY
    }
    
    func getUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }

    func getMpcKeys() throws -> [KeyDescriptor] {
        return try initializeCore().getKeysStatus()
    }

    func generateKeys() async throws -> Set<KeyDescriptor> {
        let algorithms: Set<Algorithm> = Set(algoArray)
        let startDate = Date()
        let result = try await initializeCore().generateMPCKeys(algorithms: algorithms)
        print("Measure - generateMpcKeys \(Date().timeIntervalSince(startDate))")
        return result
    }
        
    func backupKeys(passphrase: String, passphraseId: String) async throws -> Set<KeyBackup> {
        return try await initializeCore().backupKeys(passphrase: passphrase, passphraseId: passphraseId)
    }
    
    func stopJoinWallet() throws {
        try initializeCore().stopJoinWallet()
    }

    func takeOver() async throws -> Set<FullKey> {
        return try await initializeCore().takeover()
    }
    
    func deriveAssetKey(privateKey: String, derivationParams: DerivationParams) async throws -> KeyData {
        return try await initializeCore().deriveAssetKey(extendedPrivateKey: privateKey, bip44DerivationParams: derivationParams)
    }

    
    func recoverWallet(resolver: FireblocksPassphraseResolver) async throws -> Bool {
        let keySet = try await initializeCore().recoverKeys(passphraseResolver: resolver)
        if keySet.isEmpty { return false }
        if keySet.first(where: {$0.keyRecoveryStatus == .ERROR}) != nil  { return false }
        startPolling()
        return true
    }
    
    func approveJoinWallet(requestId: String) async throws -> Set<JoinWalletDescriptor> {
        return try await initializeCore().approveJoinWalletRequest(requestId: requestId)
    }

    func addDevice(joinWalletHandler: FireblocksJoinWalletHandler) async throws -> Bool {
        let startDate = Date()
        let result = try await initializeCore().requestJoinExistingWallet(joinWalletHandler: joinWalletHandler)
        print("Measure - addDevice \(Date().timeIntervalSince(startDate))")

        let didFail = result.filter({$0.keyStatus != .READY}).count > 0 || result.filter({$0.keyStatus == .READY}).count == 0
        if !didFail {
            startPolling()
        }
        
        return !didFail
    }

    func signTransaction(transactionId: String) async throws -> Bool {
        let startDate = Date()
        let result = try await initializeCore().signTransaction(txId: transactionId)
        print("Measure - signTransaction \(Date().timeIntervalSince(startDate))")
        return result.transactionSignatureStatus == .COMPLETED
    }
    
    func stopTransaction() throws {
        try initializeCore().stopSignTransaction()
    }
    
    func signOutFlow() throws {
        try Auth.auth().signOut()
        stopPollingMessages()
        TransfersViewModel.shared.signOut()
        AssetListViewModel.shared.signOut()
        try? stopJoinWallet()
        UsersLocalStorageManager.shared.resetAuthProvider()
        SignInViewModel.shared.launchView = nil
        FireblocksManager.shared.deviceId = ""
        FireblocksManager.shared.walletId = ""
        FireblocksManager.shared.latestBackupDeviceId = ""
    }


}
