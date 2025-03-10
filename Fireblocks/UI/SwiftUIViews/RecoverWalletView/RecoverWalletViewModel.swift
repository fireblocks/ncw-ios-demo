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
        var coordinator: Coordinator?
        var googleSignInManager: GoogleSignInManager?
        var fireblocksManager: FireblocksManager?
        let googleDriveManager = GoogleDriveManager()
        let redirect: Bool
        var gidUser: GIDGoogleUser?
        
        @Published var dismiss: Bool = false
        
        @Published var isSucceeded: Bool = false
        
        init(redirect: Bool) {
            self.redirect = redirect
        }
        
        func setup(loadingManager: LoadingManager, fireblocksManager: FireblocksManager, googleSignInManager: GoogleSignInManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.coordinator = coordinator
            self.fireblocksManager = fireblocksManager
            self.googleSignInManager = googleSignInManager
            if redirect {
                fireblocksManager.deviceId = fireblocksManager.latestBackupDeviceId
            }
        }
        
        @MainActor
        func recover() {
            do {
                guard let fireblocksManager else {
                    return
                }
                
                if fireblocksManager.latestBackupDeviceId.isTrimmedEmpty {
                    return
                }
                                
                let _ = try fireblocksManager.initializeCore()
                self.loadingManager.setLoading(value: true)
                Task {
                    self.gidUser = await gidUser()
                    let result = try await fireblocksManager.recoverWallet(resolver: self)
                    await MainActor.run {
                        self.loadingManager.setLoading(value: false)
                        if result, let email = fireblocksManager.getUserEmail() {
                            let deviceId = fireblocksManager.deviceId
                            UsersLocalStorageManager.shared.setLastDeviceId(deviceId: deviceId, email: email)
                            
                            if redirect {
                                fireblocksManager.startPolling()
                                SignInViewModel.shared.launchView = NavigationContainerView {
                                    TabBarView()
                                }
                            } else {
                                self.coordinator?.path = NavigationPath()
                            }
                        } else {
                            self.loadingManager.setAlertMessage(error: CustomError.recover)
                        }
                    }
                }
            } catch {
                self.loadingManager.setLoading(value: false)
                self.loadingManager.setAlertMessage(error: error)
            }
        }
        
        func gidUser() async -> GIDGoogleUser? {
            if let _ = UsersLocalStorageManager.shared.getAuthProvider() {
                if await AuthRepository.getUserIdToken() != nil {
                    return try? await GIDSignIn.sharedInstance.restorePreviousSignIn()
                }
            }
            
            return nil
        }

        func resolve(passphraseId: String, callback: @escaping (String) -> ()) {
            if let gidUser = self.gidUser {
                Task {
                    let passphrase = await self.googleDriveManager.recoverFromDrive(gidUser: gidUser, passphraseId: passphraseId)
                    callback(passphrase ?? "")
                }
            } else {
                DispatchQueue.main.async {
                    self.authenticateUser(passphraseId: passphraseId) { passphrase in
                        callback(passphrase ?? "")
                    }
                }
            }
        }
        
        @MainActor
        private func authenticateUser(passphraseId: String, callback: @escaping (String?) -> ()) {
            guard let gidConfig = googleSignInManager?.getGIDConfiguration() else {
                print("❌ BackupWalletView, gidConfig is nil.")
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
