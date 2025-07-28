//
//  SignInViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/01/2025.
//

import UIKit
import SwiftUI

//EW
class SignInViewModel: SignInView.ViewModel {
    static let shared = SignInViewModel()
    private var foregroundObserver: NSObjectProtocol?

    
    override func handleSuccessSignIn(isLaunch: Bool = false) async -> Error? {
        guard let fireblocksManager else {
            let error: CustomError = CustomError.genericError("Failed to load Fireblocks Manager")
            loadingManager?.setAlertMessage(error: error)
            return error
        }
        
        do {
            try await fireblocksManager.assignWallet()
            guard let email = fireblocksManager.getUserEmail() else {
                let error: CustomError = CustomError.login
                loadingManager?.setAlertMessage(error: error)
                return error
            }
            
            let state = await fireblocksManager.getLatestBackupState()
            UsersLocalStorageManager.shared.setLastLoggedInEmail(email: email)
                        
            await fireblocksManager.registerPushNotificationToken()
            
            foregroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { _ in
                FireblocksManager.shared.appWillEnterForeground()
            }
            
            switch state {
            case .generate:
                self.launchView = NavigationContainerView {
                    SpinnerViewContainer {
                        GenerateKeysView()
                    }
                }
            case .exist:
                if try userHasKeys() {
                    fireblocksManager.startPolling()
                    self.launchView = NavigationContainerView {
                        TabBarView()
                    }
                } else {
                    self.launchView = NavigationContainerView {
                        SpinnerViewContainer {
                            GenerateKeysView()
                        }
                    }
                }
            case .joinOrRecover:
                self.launchView = NavigationContainerView {
                    SpinnerViewContainer {
                        JoinOrRecoverView()
                    }
                }
            case .error(let error):
                loadingManager?.setAlertMessage(error: error)
                return error
            }
            return nil
        } catch {
            loadingManager?.setAlertMessage(error: error)
            return error
        }
    }
    
    deinit {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
