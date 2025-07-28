//
//  SettingsViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import Foundation
import FirebaseAuth
import UIKit
import SwiftUI

@Observable
class SettingsViewModel {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    
    var settingsWalletActions: [SettingsData] = []
//    var settingsGeneralActions: [SettingsData] = []
    var advanceInfoAction: SettingsData?
    var signOutAction: SettingsData?
    
    var isShareLogsPresented = false
    var isDiscardAlertPresented = false
    var items: [URL] = []
    
    var currentUser: User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    init() {
        if let fireblocksLogsURL = FireblocksManager.shared.getURLForLogFiles() {
            items.append(fireblocksLogsURL)
        }
        let walletActions = [
            SettingsData(icon: "settingsBackup", title: "Create a backup", subtitle: nil, action: {
                self.coordinator?.path.append(NavigationTypes.backup(false))
            }),
            SettingsData(icon: "settingsRecover", title: "Recover wallet", subtitle: nil, action: {
                self.coordinator?.path.append(NavigationTypes.recoverWallet(false))
            }),
            SettingsData(icon: "settingsExport", title: "View private keys", subtitle: nil, action: {
                self.coordinator?.path.append(NavigationTypes.takeover)
            }),
            SettingsData(icon: "settingsAddNewDevice", title: "Add new device", subtitle: nil, action: {
                self.coordinator?.path.append(NavigationTypes.joinDevice)
            })
        ]
        
        self.settingsWalletActions = walletActions
        
        #if DEV
        self.settingsWalletActions.append(
            SettingsData(icon: "settingsExport", title: "Generate keys", subtitle: nil, action: {
                SignInViewModel.shared.launchView = NavigationContainerView {
                    SpinnerViewContainer {
                        GenerateKeysView()
                    }
                }
            })
        )
        #endif
    }
    
    func setup(coordinator: Coordinator, loadingManager: LoadingManager) {
        self.coordinator = coordinator
        self.loadingManager = loadingManager
        self.advanceInfoAction = SettingsData(icon: "settingsAdvancedInfo", title: "Advanced info", subtitle: nil, action: {
            self.coordinator?.path.append(NavigationTypes.info)

        })
        self.signOutAction = SettingsData(icon: "settingsSignOut", title: "Sign out", subtitle: nil, action: {
            self.isDiscardAlertPresented = true
        })

    }
    
    func stopPollingMessages() {
        FireblocksManager.shared.stopPollingMessages()
    }
    
    @MainActor
    func signOutFromFirebase() {
        do {
            try FireblocksManager.shared.signOut()
        } catch {
            self.loadingManager?.setAlertMessage(error: error)
        }
    }
    
    func getUrlOfProfilePicture() -> URL? {
        if let photoURL = currentUser?.photoURL {
            print(photoURL)
            let highResPhotoURLString = photoURL.absoluteString.replacingOccurrences(of: "s96-c", with: "s400-c")
            return URL(string: highResPhotoURLString)
        }
        
        return nil
    }
    
    func getUserName() -> String {
        return currentUser?.displayName ?? ""
    }
    
    func getUserEmail() -> String {
        return currentUser?.email ?? ""
    }
}

class SettingsViewModelMock: SettingsViewModel {
    override func getUrlOfProfilePicture() -> URL? {
        return URL(string: "https://fireblocks.com/images/fireblocks-logo-white.png")
    }
    
    override func getUserName() -> String {
        return "Dudi Shani-Gabay"
    }
    
    override func getUserEmail() -> String {
        return "dsgabay@fireblocks.com"
    }

}
