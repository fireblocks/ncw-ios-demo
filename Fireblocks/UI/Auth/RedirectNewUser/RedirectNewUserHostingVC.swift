//
//  RedirectNewUserHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 25/01/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
class RedirectNewUserHostingVC: FBHostingViewController {
    let viewModel: RedirectNewUserView.ViewModel

    init() {
        self.viewModel = RedirectNewUserView.ViewModel()
        let view = RedirectNewUserView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInit() {
        viewModel.delegate = self
    }

}

extension RedirectNewUserHostingVC: RedirectNewUserDelegate {
    func signOut() {
        try? Auth.auth().signOut()
        if let window = view.window {
            let viewModel = LaunchView.ViewModel()
            let rootViewController = UIHostingController(
                rootView: NavigationContainerView() {
                    LaunchView(viewModel: viewModel)
                }
            )
            window.rootViewController = rootViewController
        }
    }
    
    func recoverTapped() {
        let vc = BackupViewController()
        vc.actionType = Recover(delegate: vc.self)
        navigationController?.pushViewController(vc, animated: true)
    }
}
