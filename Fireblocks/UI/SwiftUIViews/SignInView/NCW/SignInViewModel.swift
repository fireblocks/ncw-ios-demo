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

    override func handleSuccessSignIn(isLaunch: Bool = false)  async {
        do {
            let _ = try await SessionManager.shared.login()
        } catch {
            print(error.localizedDescription)
            return
        }

        guard let state = await fireblocksManager?.getLatestBackupState() else {
            print("Failed to getLatestBackupState")
            return
        }
        
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return
        }

        switch state {
        case .generate:
            if let _ = await fireblocksManager?.assignWallet() {
                let view = NavigationContainerView {
                    SpinnerViewContainer {
                        GenerateKeysView()
                    }
                }

                let vc = UIHostingController(rootView: view)
                window.rootViewController = vc
            }
        case .exist:
            if userHasKeys {
                if let _ = await fireblocksManager?.assignWallet() {
                    fireblocksManager?.startPolling()
                    self.launchView = NavigationContainerView {
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
            print("error")
        }


    }
    
    override func clearWallet() {
        
    }

}
