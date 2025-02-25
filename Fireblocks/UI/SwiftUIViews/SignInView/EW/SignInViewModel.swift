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
        if let _ = await fireblocksManager?.assignWallet() {
//            UsersLocalStorageManager.shared.setDidSignIn(value: true)
            guard let state = await fireblocksManager?.getLatestBackupState() else {
                return
            }

            switch state {
            case .generate:
                self.launchView = NavigationContainerView {
                    SpinnerViewContainer {
                        GenerateKeysView()
                    }
                }
            case .exist:
                if userHasKeys {
                    fireblocksManager?.startPolling()
                    self.launchView = NavigationContainerView {
                        SpinnerViewContainer {
                            TabBarView()
                        }
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

//                coordinator?.path.append(NavigationTypes.joinOrRecover)
            case .error:
                print("error")
            }
        }
    }
}
