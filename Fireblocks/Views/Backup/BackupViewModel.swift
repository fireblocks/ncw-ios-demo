//
//  BackupViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleSignIn
import SwiftUI
import FireblocksSDK
import CloudKit

extension BackupView {
    class ViewModel: ObservableObject {
        
        @Published var showLoader = false
        @Published var backupProvider: BackupProvider?
        @Published var backupData: BackupData?
        @Published var navigationType: NavigationTypes?

        private let repository = BackupRepository()
        private var appRootManager: AppRootManager?
        private var authRepository: AuthRepository?
        private var bannerErrorsManager: BannerErrorsManager?

        private let googleDriveScope = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
        private var task: Task<Void, Never>?

        let bridge = BridgeVCView()

        lazy var actionType: BackupViewControllerStrategy = { Backup(delegate: self) }()

        func setup(appRootManager: AppRootManager, authRepository: AuthRepository, bannerErrorsManager: BannerErrorsManager) {
            self.appRootManager = appRootManager
            self.authRepository = authRepository
            self.bannerErrorsManager = bannerErrorsManager
        }

        func checkIfBackupExist() {
            showLoader = true
            task = Task {
                if let backupInfo = await getBackupInfo() {
                    backupData = BackupData(backupInfo: backupInfo)
                } else {
                    DispatchQueue.main.async {
                        self.showLoader = false
                    }
                }
            }
        }

        func getPassphraseInfo(location: BackupProvider) async -> PassphraseInfo {
            return await repository.getPassphraseInfos()?.passphrases.last ?? PassphraseInfo(passphraseId: FireblocksManager.shared.generatePassphraseId(), location: location)
        }

        func getBackupDetails() -> String {
            if let backupData {
                let backupDate = backupData.date ?? "-"
                let backupDetails = LocalizableStrings.backupDateAndAccount
                    .replacingOccurrences(of: "{date}", with: backupDate)
                    .replacingOccurrences(of: "{backup_provider}", with: backupData.title ?? "-")
                
                return backupDetails
            } else {
                return LocalizableStrings.backupExplanation
            }
        }

        func getBackupInfo() async -> BackupInfo? {
            return await repository.getBackupInfo()
        }
        

        func getError() -> String {
            return LocalizableStrings.failedToCreateKeyBackup
        }

        func backup(backupProvider: BackupProvider) {
            showLoader = true
            switch backupProvider {
            case .iCloud:
                task = Task {
                    let passphraseInfo = await getPassphraseInfo(location: .iCloud)
                    actionType.performICloudAction(passphraseId: passphraseInfo.passphraseId)
                }
            case .GoogleDrive:
                task = Task {
                    let passphraseInfo = await getPassphraseInfo(location: .GoogleDrive)
                    authenticateUser(passphraseId: passphraseInfo.passphraseId) { _ in
                    }
                }

            }
        }
    }
}

extension BackupView.ViewModel: BackupProviderDelegate {
    func backupToGoogleDrive(_ gidUser: GIDGoogleUser, passphraseId: String) {
        task = Task {
            let result = await repository.backupToGoogleDrive(gidUser: gidUser, passphraseId: passphraseId)
            if result {
                navigationType = .BackupSucceeded
            } else {
                bannerErrorsManager?.errorMessage = getError()
            }
        }
    }
    
    func backupToICloud(passphraseId: String) {
        task = Task {
            guard let container = await getCKContainer() else {
                bannerErrorsManager?.errorMessage = getError()
                return
            }
            
            let result = await repository.backupToICloud(container: container, passphraseId: passphraseId)
            if result {
                navigationType = .BackupSucceeded
            } else {
                bannerErrorsManager?.errorMessage = getError()
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
            
            actionType.performDriveAction(gidUser, passphraseId: passphraseId, callback: callback)
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
