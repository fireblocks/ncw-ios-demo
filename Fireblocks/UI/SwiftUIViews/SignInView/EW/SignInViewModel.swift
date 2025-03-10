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
    
    override func handleSuccessSignIn(isLaunch: Bool = false) async {
        guard let fireblocksManager else {
            loadingManager.setAlertMessage(error: CustomError.genericError("Failed to load Fireblocks Manager"))
            return
        }
        
        do {
            try await fireblocksManager.assignWallet()
            guard let email = fireblocksManager.getUserEmail() else {
                loadingManager.setAlertMessage(error: CustomError.login)
                return
            }
            
            let state = await fireblocksManager.getLatestBackupState()
            UsersLocalStorageManager.shared.setLastLoggedInEmail(email: email)
            
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
                loadingManager.setAlertMessage(error: error)
            }
        } catch {
            loadingManager.setAlertMessage(error: error)
        }
    }
}
