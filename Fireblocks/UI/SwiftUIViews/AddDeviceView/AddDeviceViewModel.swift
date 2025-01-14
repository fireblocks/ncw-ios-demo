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
        private var loadingManager: LoadingManager!
        private var coordinator: Coordinator!
        var fireblocksManager: FireblocksManager?
        
        private var mpcKeyTask: Task<Void, Never>?
        
        func setup(loadingManager: LoadingManager, coordinator: Coordinator, fireblocksManager: FireblocksManager) {
            self.loadingManager = loadingManager
            self.fireblocksManager = fireblocksManager
            self.coordinator = coordinator
        }
        
        func requestJoinWallet() {
            guard let fireblocksManager else { return }
            fireblocksManager.deviceId = fireblocksManager.generateDeviceId()
            
            loadingManager.isLoading = true
            Task {
                do {
                    let _ = try await SessionManager.shared.joinWallet(deviceId: fireblocksManager.deviceId, walletId: fireblocksManager.walletId)
                    try fireblocksManager.initializeFireblocksSDK()
                    
                    let addDeviceResult = await fireblocksManager.addDevice(joinWalletHandler: self)
                    await MainActor.run {
                        self.isKeysGenerated(isGenerated: addDeviceResult)
                        self.loadingManager.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.isKeysGenerated(isGenerated: false)
                        self.loadingManager.isLoading = false
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
                
                self.loadingManager.isLoading = false
                self.coordinator.path.append(NavigationTypes.addDeviceQR(requestId, email))
            }
        }
        
        func onProvisionerFound() {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("onProvisionerFound"), object: nil, userInfo: nil)
            }
        }
        
        @MainActor
        func onAddingDevice(success: Bool) {
            self.loadingManager.isLoading = false
            NotificationCenter.default.post(name: Notification.Name("onAddingDevice"), object: nil, userInfo: nil)
            if success {
                guard let deviceId = self.fireblocksManager?.deviceId, let email = self.fireblocksManager?.getUserEmail() else {
                    return
                }
                
                UsersLocalStorageManager.shared.setLastDeviceId(deviceId: deviceId, email: email)
                
                let vm = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceSucceeded.rawValue, title: LocalizableStrings.addDeviceAdded, buttonTitle: LocalizableStrings.goHome, actionButton:  {
                    guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
                        return
                    }
                    
                    
                    self.fireblocksManager?.startPolling()
                    let vc = UINavigationController(rootViewController: TabBarViewController())
                    window.rootViewController = vc
                }, didFail: false)
                
                self.coordinator.path.append(NavigationTypes.feedback(vm))
                
            } else {
                let vm = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceFailed.rawValue, title: LocalizableStrings.addDeviceFailedTitle, subTitle: LocalizableStrings.addDeviceFailedSubtitle, buttonTitle: LocalizableStrings.goHome, actionButton:  {
                    self.coordinator.path = NavigationPath()
                }, didFail: true)
                self.coordinator.path.append(NavigationTypes.feedback(vm))
            }
        }
    }
}
