//
//  BackupWalletViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/02/2025.
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

extension BackupWalletView {
    class ViewModel: ObservableObject {
        private var coordinator: Coordinator?
        private var loadingManager: LoadingManager?
        var googleSignInManager: GoogleSignInManager?
        var fireblocksManager: FireblocksManager?
        let googleDriveManager = GoogleDriveManager()
        private let repository = BackupRepository()
        let redirect: Bool
        var gidUser: GIDGoogleUser?
        
        @Published var dismiss: Bool = false
        @Published var isSucceeded: Bool = false
        
        init(redirect: Bool) {
            self.redirect = redirect
        }
        
        func setup(loadingManager: LoadingManager, fireblocksManager: FireblocksManager, googleSignInManager: GoogleSignInManager, coordinator: Coordinator) {
            self.loadingManager = loadingManager
            self.fireblocksManager = fireblocksManager
            self.googleSignInManager = googleSignInManager
            self.coordinator = coordinator
        }
        
        @MainActor func backup() {
            self.loadingManager?.setLoading(value: true)
            Task {
                let passphraseInfo = await getPassphraseInfo(location: .GoogleDrive)
                if let gidUser = await gidUser() {
                    do {
                        let result = try await repository.backupToGoogleDrive(gidUser: gidUser, passphraseId: passphraseInfo.passphraseId)
                        self.loadingManager?.setLoading(value: false)
                        let viewModel: EndFlowFeedbackView.ViewModel
                        if result {
                            viewModel = EndFlowFeedbackView.ViewModel(icon: nil, title: "Your recovery key is backed up!", navigationBarTitle: LocalizableStrings.backupYourKeys, buttonIcon: nil, buttonTitle: LocalizableStrings.goHome, actionButton: {
                                if self.redirect {
                                    SignInViewModel.shared.launchView = NavigationContainerView {
                                        TabBarView()
                                    }
                                } else {
                                    self.coordinator?.path = NavigationPath()
                                }
                            }, rightToolbarItemIcon: nil, rightToolbarItemAction: nil, didFail: false, canGoBack: false)
                            coordinator?.path.append(NavigationTypes.feedback(viewModel))
                        } else {
                            let error = FireblocksManager.shared.getError(.backup, defaultError: CustomError.backup)
                            self.loadingManager?.setAlertMessage(error: error)
                        }
                    } catch {
                        self.loadingManager?.setAlertMessage(error: error)
                    }
                } else {
                    authenticateUser(passphraseId: passphraseInfo.passphraseId) { [weak self] result in
                        if let self {
                            self.loadingManager?.setLoading(value: false)
                        }
                    }
                }
            }
        }
        
        func getPassphraseInfo(location: BackupProvider) async -> PassphraseInfo {
            return await repository.getPassphraseInfos()?.passphrases.last ?? PassphraseInfo(passphraseId: FireblocksManager.shared.generatePassphraseId(), location: location)
        }

        
        func gidUser() async -> GIDGoogleUser? {
            if let _ = UsersLocalStorageManager.shared.getAuthProvider() {
                if await AuthRepository.getUserIdToken() != nil {
                    return try? await GIDSignIn.sharedInstance.restorePreviousSignIn()
                }
            }
            
            return nil
        }

        @MainActor
        private func authenticateUser(passphraseId: String, callback: @escaping (Bool) -> ()) {
            guard let gidConfig = googleSignInManager?.getGIDConfiguration() else {
                print("❌ BackupWalletView, gidConfig is nil.")
                return callback(false)
            }
            
            guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
                return callback(false)
            }

            GIDSignIn.sharedInstance.configuration = gidConfig
            GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: googleSignInManager?.googleDriveScope
            ) { [unowned self] result, error in
                
                guard error == nil else {
                    print("Authentication failed with: \(String(describing: error?.localizedDescription)).")
                    return callback(false)
                }
                
                guard let gidUser = result?.user else {
                    print("GIDGoogleUser is nil")
                    return callback(false)
                }
                
                Task {
                    do {
                        let result = try await repository.backupToGoogleDrive(gidUser: gidUser, passphraseId: passphraseId)
                        callback(result)
                    } catch {
                        self.loadingManager?.setAlertMessage(error: error)
                        return callback(false)
                    }
                }
            }
        }
    }
}
