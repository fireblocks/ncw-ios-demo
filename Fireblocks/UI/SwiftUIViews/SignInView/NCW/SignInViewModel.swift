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
        let state = await fbManager.getLatestBackupState()
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return
        }

        if let _ = await fbManager.assignWallet() {
            switch state {
            case .generate:
                let vc = UINavigationController(rootViewController: MpcKeysViewController(isAddingDevice: false))
                window.rootViewController = vc
            case .exist:
                if userHasKeys {
                    let vc = UINavigationController(rootViewController: TabBarViewController())
                    window.rootViewController = vc
                } else {
                    let vc = UINavigationController(rootViewController: MpcKeysViewController(isAddingDevice: false))
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
