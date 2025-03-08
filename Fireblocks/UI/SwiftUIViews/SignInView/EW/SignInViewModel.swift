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
            guard let state = await fireblocksManager?.getLatestBackupState() else {
                return
            }

            switch state {
            case .generate:
                withAnimation {
                    self.launchView = NavigationContainerView {
                        SpinnerViewContainer {
                            GenerateKeysView()
                        }
                    }
                }
            case .exist:
                if userHasKeys {
                    fireblocksManager?.startPolling()
                    withAnimation {
                        self.launchView = NavigationContainerView {
                            TabBarView()
                        }
                    }
                } else {
                    withAnimation {
                        self.launchView = NavigationContainerView {
                            SpinnerViewContainer {
                                GenerateKeysView()
                            }
                        }
                    }
                }
            case .joinOrRecover:
                withAnimation {
                    self.launchView = NavigationContainerView {
                        SpinnerViewContainer {
                            JoinOrRecoverView()
                        }
                    }
                }
            case .error:
                print("error")
            }
        }
    }
}
