//
//  SignInViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/01/2025.
//
import UIKit
import SwiftUI

//NCW
class SignInViewModel: SignInView.ViewModel {
    static let shared = SignInViewModel()

    override func handleSuccessSignIn(isLaunch: Bool = false) async -> Error? {
        do {
            let _ = try await SessionManager.shared.login()
            
            guard let fireblocksManager else {
                let error: CustomError = CustomError.genericError("Failed to load Fireblocks Manager")
                loadingManager?.setAlertMessage(error: error)
                return error
            }
            
            guard let email = fireblocksManager.getUserEmail() else {
                let error: CustomError = CustomError.genericError("Failed to getUserEmail")
                loadingManager?.setAlertMessage(error: error)
                return error
            }
            
            let state = await fireblocksManager.getLatestBackupState()
            UsersLocalStorageManager.shared.setLastLoggedInEmail(email: email)
            switch state {
            case .generate:
                try await fireblocksManager.assignWallet()
                self.fireblocksManager?.didClearWallet = false
                self.launchView = NavigationContainerView {
                    SpinnerViewContainer {
                        GenerateKeysView()
                    }
                }
            case .exist:
                if try userHasKeys() {
                    try await fireblocksManager.assignWallet()
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
                if isLaunch {
                    self.launchView = NavigationContainerView {
                        SpinnerViewContainer {
                            JoinOrRecoverView()
                        }
                    }
                } else {
                    coordinator?.path.append(NavigationTypes.joinOrRecover)
                }
            case .error:
                let error: CustomError = CustomError.assignWallet
                loadingManager?.setAlertMessage(error: error)
                return error
            }
            return nil
        } catch {
            loadingManager?.setAlertMessage(error: error)
            return error
        }
    }
    
}
