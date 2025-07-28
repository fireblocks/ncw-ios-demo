//
//  AddDeviceViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

extension AddDeviceView {
    class ViewModel: ObservableObject, FireblocksJoinWalletHandler {
        private var loadingManager: LoadingManager?
        private var coordinator: Coordinator?
        var fireblocksManager: FireblocksManager?
        
        private var mpcKeyTask: Task<Void, Never>?
        var didLoad = false
        
        func setup(loadingManager: LoadingManager, coordinator: Coordinator, fireblocksManager: FireblocksManager) {
            if !didLoad {
                didLoad = true
                self.loadingManager = loadingManager
                self.fireblocksManager = fireblocksManager
                self.coordinator = coordinator
            }
        }
        
        @MainActor
        func requestJoinWallet() {
            guard let fireblocksManager else { return }
            fireblocksManager.deviceId = fireblocksManager.generateDeviceId()
            
            self.loadingManager?.setLoading(value: true)
            Task {
                do {
                    let _ = try await SessionManager.shared.joinWallet(deviceId: fireblocksManager.deviceId, walletId: fireblocksManager.walletId)
                    let _ = try fireblocksManager.initializeCore()
                    
                    let addDeviceResult = try await fireblocksManager.requestJoinExistingWallet(joinWalletHandler: self)
                    await MainActor.run {
                        self.isKeysGenerated(isGenerated: addDeviceResult)
                        self.loadingManager?.setLoading(value: false)
                    }
                } catch {
                    await MainActor.run {
                        self.isKeysGenerated(isGenerated: false)
                        self.loadingManager?.setLoading(value: false)
                    }
                }
            }
        }
        
        @MainActor
        func isKeysGenerated(isGenerated: Bool) {
            self.onAddingDevice(success: isGenerated)
        }
        
        func onRequestId(requestId: String) {
            DispatchQueue.main.async {
                guard let email = self.fireblocksManager?.getUserEmail() else {
                    return
                }
                
                self.loadingManager?.setLoading(value: false)
                self.coordinator?.path.append(NavigationTypes.addDeviceQR(requestId, email))
            }
        }
        
        func onProvisionerFound() {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("onProvisionerFound"), object: nil, userInfo: nil)
            }
        }
        
        @MainActor
        func onAddingDevice(success: Bool) {
            self.loadingManager?.setLoading(value: false)
            NotificationCenter.default.post(name: Notification.Name("onAddingDevice"), object: nil, userInfo: nil)
            if success {
                guard let deviceId = self.fireblocksManager?.deviceId, let email = self.fireblocksManager?.getUserEmail() else {
                    return
                }
                
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: deviceId, email: email)
                
                let vm = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceSucceeded.rawValue, title: LocalizableStrings.addDeviceAdded, buttonTitle: LocalizableStrings.goHome, actionButton:  {
                    
                    self.fireblocksManager?.startPolling()
                    SignInViewModel.shared.launchView = NavigationContainerView {
                        TabBarView()
                    }
                }, didFail: false, canGoBack: false)
                
                self.coordinator?.path.append(NavigationTypes.feedback(vm))
                
            } else {
//                let vm = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceFailed.rawValue, title: LocalizableStrings.addDeviceFailedTitle, subTitle: LocalizableStrings.addDeviceFailedSubtitle, buttonTitle: LocalizableStrings.goHome, actionButton:  {
//                    self.coordinator?.path = NavigationPath()
//                }, didFail: true)
//                self.coordinator?.path.append(NavigationTypes.feedback(vm))
                
//                try? self.fireblocksManager?.stopJoinWallet()
                let error = FireblocksManager.shared.getError(.keyCreation, defaultError: CustomError.joinWallet)
                self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }
}
