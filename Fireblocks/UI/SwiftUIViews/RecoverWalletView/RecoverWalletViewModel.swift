//
//  RecoverWalletViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Drive
import UIKit

#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

extension RecoverWalletView {
    class ViewModel: ObservableObject, FireblocksPassphraseResolver {
        private var loadingManager: LoadingManager!
        var googleSignInManager: GoogleSignInManager?
        var fireblocksManager: FireblocksManager?
        let googleDriveManager = GoogleDriveManager()
        let redirect: Bool
        @Published var dismiss: Bool = false
        
        @Published var isSucceeded: Bool = false
        
        init(redirect: Bool) {
            self.redirect = redirect
        }
        
        func setup(loadingManager: LoadingManager, fireblocksManager: FireblocksManager, googleSignInManager: GoogleSignInManager) {
            self.loadingManager = loadingManager
            self.fireblocksManager = fireblocksManager
            self.googleSignInManager = googleSignInManager
            if redirect {
                fireblocksManager.deviceId = fireblocksManager.latestBackupDeviceId
            }
        }
        
        func recover() {
            do {
                guard let fireblocksManager else {
                    return
                }
                
                if fireblocksManager.latestBackupDeviceId.isTrimmedEmpty {
                    return
                }
                
                try fireblocksManager.initializeFireblocksSDK()
                loadingManager.isLoading = true
                Task {
                    let result = await fireblocksManager.recoverWallet(resolver: self)
                    await MainActor.run {
                        loadingManager.isLoading = false
                        if result, let email = fireblocksManager.getUserEmail() {
                            let deviceId = fireblocksManager.deviceId
                            UsersLocalStorageManager.shared.setLastDeviceId(deviceId: deviceId, email: email)
                            
                            if redirect {
                                guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
                                    return
                                }
                                
                                fireblocksManager.startPolling()
                                let vc = UINavigationController(rootViewController: TabBarViewController())
                                window.rootViewController = vc
                            } else {
                                dismiss = true
                            }
                        } else {
                            
                        }
                    }
                }
            } catch {
                return
            }
        }
        
        func resolve(passphraseId: String, callback: @escaping (String) -> ()) {
            DispatchQueue.main.async {
                self.authenticateUser(passphraseId: passphraseId) { passphrase in
                    callback(passphrase ?? "")
                }
            }
        }
        
        @MainActor
        private func authenticateUser(passphraseId: String, callback: @escaping (String?) -> ()) {
            guard let gidConfig = googleSignInManager?.getGIDConfiguration() else {
                print("❌ BackupViewController, gidConfig is nil.")
                return callback(nil)
            }
            
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                return callback(nil)
            }

            GIDSignIn.sharedInstance.configuration = gidConfig
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: googleSignInManager?.googleDriveScope
            ) { [unowned self] result, error in
                
                guard error == nil else {
                    print("Authentication failed with: \(String(describing: error?.localizedDescription)).")
                    return callback(nil)
                }
                
                guard let gidUser = result?.user else {
                    print("GIDGoogleUser is nil")
                    return callback(nil)
                }
                
                Task {
                    let passphrase = await self.googleDriveManager.recoverFromDrive(gidUser: gidUser, passphraseId: passphraseId)
                    callback(passphrase)
                }
            }
        }
    }
}
