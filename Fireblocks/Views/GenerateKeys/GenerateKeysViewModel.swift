//
//  GenerateKeysViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation
import FirebaseAuth

extension GenerateKeysView {
    class ViewModel: ObservableObject {
        private var task: Task<Void, Never>?
        private var appRootManager: AppRootManager?
        private var bannerErrorsManager: BannerErrorsManager?

        @Published var showLoader = false
        @Published var navigationType: NavigationTypes?
        
        func setup(appRootManager: AppRootManager, bannerErrorsManager: BannerErrorsManager) {
            self.appRootManager = appRootManager
            self.bannerErrorsManager = bannerErrorsManager
        }

        func signOut() {
            try? Auth.auth().signOut()
            self.appRootManager?.currentRoot = .login
        }
        
        func generateMPCKeys() {
            showLoader = true
            task = Task {
                await FireblocksManager.shared.generateMpcKeys(self)
            }

        }

    }
}

extension GenerateKeysView.ViewModel:  FireblocksKeyCreationDelegate {
    func isKeysGenerated(isGenerated: Bool, didJoin: Bool = false, error: String? = nil) {
        DispatchQueue.main.async {
            if isGenerated {
                self.showLoader = false
                self.navigationType = .GenerateSucceeded
            } else {
                self.showLoader = false
                self.bannerErrorsManager?.errorMessage = error ?? LocalizableStrings.mpcKeysGenerationFailed
            }
        }
    }
}

