//
//  RecoverViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 12/03/2024.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleSignIn
import SwiftUI
import FireblocksSDK
import CloudKit

extension RecoverView {
    class ViewModel: ObservableObject {
        @Published var showLoader = false
        @Published var backupProvider: BackupProvider?
        @Published var backupData: BackupData?
        @Published var didSucceeded = false

        private let googleDriveScope = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
        private var task: Task<Void, Never>?
        private let repository = BackupRepository()
        private var appRootManager: AppRootManager?
        private var authRepository: AuthRepository?
        private var bannerErrorsManager: BannerErrorsManager?
        private var isFirstRecover = false
        
        let bridge = BridgeVCView()

        func setup(appRootManager: AppRootManager, authRepository: AuthRepository, bannerErrorsManager: BannerErrorsManager, isFirstRecover: Bool) {
            self.appRootManager = appRootManager
            self.authRepository = authRepository
            self.bannerErrorsManager = bannerErrorsManager
            self.isFirstRecover = isFirstRecover
        }

        func getRecoverButtonTitle() -> String {
            switch backupProvider {
            case .iCloud:
                return LocalizableStrings.recoverFromICloud
            case .GoogleDrive:
                return LocalizableStrings.recoverFromDrive
            case nil:
                return ""
            }
        }
        
        func getRecoverButtonIcon() -> Image? {
            switch backupProvider {
            case .iCloud:
                return Image(.appleIcon)
            case .GoogleDrive:
                return Image(.googleIcon)
            case nil:
                return nil
            }
        }
        
        func checkIfBackupExist() {
            showLoader = true
            task = Task {
                if let backupInfo = await getBackupInfo() {
                    DispatchQueue.main.async {
                        self.backupData = BackupData(backupInfo: backupInfo)
                        self.isBackupExist(self.backupData)
                    }
                } else {
                    isBackupExist(nil)
                }
            }
        }

        func isBackupExist(_ backupData: BackupData?) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                showLoader = false
                if let backupData = backupData, let location = backupData.location {
                    if location == BackupProvider.GoogleDrive.rawValue {
                        backupProvider = .GoogleDrive
                    } else if location == BackupProvider.iCloud.rawValue {
                        backupProvider = .iCloud
                    }
                } else {
                    bannerErrorsManager?.errorMessage = getError()
                }
            }
        }

        func getBackupInfo() async -> BackupInfo? {
            return await repository.getBackupInfo()
        }
        

        func getError() -> String {
            return LocalizableStrings.failedToRecoverWallet
        }

    }
}

extension RecoverView.ViewModel {
    func recover() {
        showLoader = true
        Task {
            let result = await FireblocksManager.shared.recoverWallet(resolver: self)
            DispatchQueue.main.async {
                self.showLoader = false
                if result {
                    if self.isFirstRecover {
                        self.appRootManager?.currentRoot = .assets
                    } else {
                        self.didSucceeded = true
                    }
                } else {
                    self.bannerErrorsManager?.errorMessage = self.getError()
                }
            }
        }

    }
    
    private func recoverFromGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String, callback: @escaping (String) -> ()) {
        task = Task {
            let passphrase = await repository.recoverFromGoogleDrive(gidUser: gidUser, passphraseId: passphraseId)
            callback(passphrase)
        }
    }

    private func recoverFromICLoud(passphraseId: String, callback: @escaping (String) -> ()) {
        task = Task {
            guard let container = await getCKContainer() else {
                callback("")
                return
            }
            
            let passphrase = await repository.recoverFromICloud(container: container, passphraseId: passphraseId)
            callback(passphrase)
        }

    }

}

extension RecoverView.ViewModel: FireblocksPassphraseResolver {
    func resolve(passphraseId: String, callback: @escaping (String) -> ()) {
        Task {
            if let backupProvider  {
                switch backupProvider {
                case .iCloud:
                    self.recoverFromICLoud(passphraseId: passphraseId, callback: callback)
                case .GoogleDrive:
                    DispatchQueue.main.async {
                        self.authenticateUser(passphraseId: passphraseId, callback: callback)
                    }
                }
            } else {
                callback("")
            }
        }
    }
    
    private func authenticateUser(passphraseId: String, callback: @escaping (String) -> ()) {
        guard let authRepository else {
            print("❌ RecoverView, authRepository is nil.")
            return
        }
        
        guard let gidConfig = authRepository.getGIDConfiguration() else {
            print("❌ RecoverView, gidConfig is nil.")
            return
        }

        GIDSignIn.sharedInstance.configuration = gidConfig
        GIDSignIn.sharedInstance.signIn(
            withPresenting: bridge.vc,
            hint: nil,
            additionalScopes: googleDriveScope
        ) { [unowned self] result, error in
            
            guard error == nil else {
                showLoader = false
                print("Authentication failed with: \(String(describing: error?.localizedDescription)).")
                return
            }
            
            guard let gidUser = result?.user else {
                showLoader = false
                print("GIDGoogleUser is nil")
                return
            }
            
            
            recoverFromGoogleDrive(gidUser, passphraseId: passphraseId, callback: callback)
        }
    }

    private func getCKContainer() async -> CKContainer? {
        do {
            let container = CKContainer.default()
            return try await container.accountStatus() == .available ? container : nil
        } catch {
            print("BackupViewModel, CKContainer account status throws: \(error).")
            return nil
        }
    }

}

