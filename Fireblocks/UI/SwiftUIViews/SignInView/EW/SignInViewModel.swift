//
//  SignInViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/01/2025.
//

import UIKit

//EW
class SignInViewModel: SignInView.ViewModel {
    override func handleSuccessSignIn(isLaunch: Bool = false) async {
        if let _ = await fireblocksManager.assignWallet() {
            UsersLocalStorageManager.shared.setDidSignIn(value: true)
            let state = await fireblocksManager.getLatestBackupState()
            guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
                return
            }

            switch state {
            case .generate:
                let vc = UINavigationController(rootViewController: MpcKeysViewController())
                window.rootViewController = vc
            case .exist:
                if userHasKeys {
                    let vc = UINavigationController(rootViewController: TabBarViewController())
                    window.rootViewController = vc
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
}
