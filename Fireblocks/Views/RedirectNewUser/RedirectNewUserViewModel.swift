//
//  RedirectNewUserViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 25/01/2024.
//

import Foundation
import FirebaseAuth

protocol RedirectNewUserDelegate: AnyObject {
    func signOut()
    func recoverTapped()
}

extension RedirectNewUserView {
    class ViewModel: ObservableObject {
        private var appRootManager: AppRootManager?
        
        func setup(appRootManager: AppRootManager) {
            self.appRootManager = appRootManager
        }
        
        func signOut() {
            try? Auth.auth().signOut()
            self.appRootManager?.currentRoot = .login
        }
        
        func addDeviceTapped() {
            try? Auth.auth().signOut()
            self.appRootManager?.currentRoot = .login
        }
    }
}
