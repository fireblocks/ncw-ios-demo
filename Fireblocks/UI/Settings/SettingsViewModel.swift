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
    var coordinator: Coordinator!
    
    var settingsWalletActions: [SettingsData] = []
    var settingsGeneralActions: [SettingsData] = []
    var isShareLogsPresented = false
    
    var appLogoURL: URL?
    var fireblocksLogsURL: URL?
    
    var currentUser: User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    init() {
        let walletActions = [
            SettingsData(icon: "settingsBackup", title: "Create a backup", subtitle: nil, action: {
                self.coordinator.path.append(NavigationTypes.backup(true))
            }),
            SettingsData(icon: "settingsRecover", title: "Recover wallet", subtitle: nil, action: {
                self.coordinator.path.append(NavigationTypes.recoverWallet(false))
            }),
            SettingsData(icon: "settingsExport", title: "Export private key", subtitle: nil, action: {
                self.coordinator.path.append(NavigationTypes.takeover)
            }),
            SettingsData(icon: "settingsAddNewDevice", title: "Add new device", subtitle: nil, action: {
                self.coordinator.path.append(NavigationTypes.joinDevice)
            })
        ]
        
        self.settingsWalletActions = walletActions
        
        #if DEV
        self.settingsWalletActions.append(
            SettingsData(icon: "settingsExport", title: "Generate keys", subtitle: nil, action: {
                self.coordinator.path.append(NavigationTypes.generateKeys)
            })
        )
        #endif
        
        let generalActions = [
            SettingsData(icon: "settingsAdvancedInfo", title: "Advanced info", subtitle: nil, action: {
                self.coordinator.path.append(NavigationTypes.info)

            }),
            SettingsData(icon: "settingsShareLogs", title: "Share logs", subtitle: nil, action: {
                guard let fireblocksLogsURL = FireblocksManager.shared.getURLForLogFiles() else {
                    print("Can't get file log url")
                    return
                }

                guard let appLogoURL = AppLoggerManager.shared.logger()?.getURLForLogFiles() else {
                    print("Can't get app file log url")
                    return
                }
                self.fireblocksLogsURL = fireblocksLogsURL
                self.appLogoURL = appLogoURL
                self.isShareLogsPresented = true
            }),
            SettingsData(icon: "settingsSignOut", title: "Sign out", subtitle: nil, action: {
                self.signOutFromFirebase()
            })
        ]

        self.settingsGeneralActions = generalActions


    }
    
    func setup(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
    func stopPollingMessages() {
        FireblocksManager.shared.stopPollingMessages()
    }
    
    func signOutFromFirebase() {
        FireblocksManager.shared.signOut()
        coordinator.path = NavigationPath()
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
