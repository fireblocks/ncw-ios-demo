//
//  SignInViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/01/2025.
//
import UIKit

//NCW
class SignInViewModel: SignInView.ViewModel {
    override func handleSuccessSignIn()  async {
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
                let vc = UINavigationController(rootViewController: MpcKeysViewController())
                window.rootViewController = vc
            }
        case .exist:
            if userHasKeys {
                if let _ = await fireblocksManager?.assignWallet() {
                    FireblocksManager.shared.startPolling()
                    let vc = UINavigationController(rootViewController: TabBarViewController())
                    window.rootViewController = vc
                }
            } else {
                let vc = UINavigationController(rootViewController: MpcKeysViewController())
                window.rootViewController = vc
            }
        case .joinOrRecover:
            coordinator?.path.append(NavigationTypes.joinOrRecover)
        case .error:
            print("error")
        }


    }
}
