//
//  StartJoinDeviceFlowViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation
import FireblocksSDK
import FirebaseAuth

extension StartJoinDeviceFlowView {
    class ViewModel: ObservableObject {
        private var task: Task<Void, Never>?
        private var appRootManager: AppRootManager?
        private var bannerErrorsManager: BannerErrorsManager?
        var email: String?
        @Published var showLoader = false
        @Published var addDeviceQRViewModel: AddDeviceQRViewModel?
        @Published var navigationType: NavigationTypes?
        
        init() {
            self.email = Auth.auth().currentUser?.email
        }
        
        func setup(appRootManager: AppRootManager, bannerErrorsManager: BannerErrorsManager) {
            self.appRootManager = appRootManager
            self.bannerErrorsManager = bannerErrorsManager
        }

        func signOut() {
            try? Auth.auth().signOut()
            self.appRootManager?.currentRoot = .login
        }
        
        func addDeviceFromSdk() {
            showLoader = true
            task = Task {
                await FireblocksManager.shared.addDevice(self, joinWalletHandler: self)
            }
        }

        private func onAddingDevice(success: Bool) {
            DispatchQueue.main.async {
                if success {
                    self.navigationType = .JoinDeviceSucceeded
                } else {
                    self.navigationType = .JoinDeviceFailed
                }
            }
        }
    }
}

extension StartJoinDeviceFlowView.ViewModel:  FireblocksKeyCreationDelegate {
    func isKeysGenerated(isGenerated: Bool, didJoin: Bool = false, error: String? = nil) {
        if didJoin {
            self.onAddingDevice(success: isGenerated)
        } else {
            if isGenerated {
//                self.createAssets()
            } else {
                DispatchQueue.main.async {
                    self.showLoader = false
                    self.bannerErrorsManager?.errorMessage = error ?? LocalizableStrings.mpcKeysGenerationFailed
                }
            }
        }
    }
}

extension StartJoinDeviceFlowView.ViewModel: FireblocksJoinWalletHandler {
    func onRequestId(requestId: String) {
        guard let email else {
            return
        }
        
        DispatchQueue.main.async {
            self.showLoader = false
            self.addDeviceQRViewModel = AddDeviceQRViewModel(requestId: requestId, email: email)
        }

    }
    
    func onProvisionerFound() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("onProvisionerFound"), object: nil, userInfo: nil)
        }
    }
}

