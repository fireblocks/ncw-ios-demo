//
//  AddDeviceQRViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth

//protocol AddDeviceQRDelegate: AnyObject {
//    func didQRTimeExpired()
//}

class AddDeviceQRViewModel: ObservableObject {
    private var loadingManager: LoadingManager!
    private var coordinator: Coordinator!
    var fireblocksManager: FireblocksManager?

    let requestId: String
    var email: String?
    var url: String?
    var expiredInterval: TimeInterval = 180.seconds
    var timer: Timer?
//    weak var delegate: AddDeviceQRDelegate?
    
    @Published var timeleft = ""
    @Published var isToolbarHidden = false
    
    init(requestId: String, email: String?, expiredInterval: TimeInterval = 180.seconds) {
        self.requestId = requestId
        self.email = email
        self.url = setURL()
        self.expiredInterval = expiredInterval
        self.startTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if let self {
                if self.isExpired() {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.timeleft = ""
                    self.didQRTimeExpired()
                } else {
                    self.timeleft = self.timeLeft()
                }
            }
        }
        timer?.fire()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onProvisionerFound), name: Notification.Name("onProvisionerFound"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAddingDevice), name: Notification.Name("onAddingDevice"), object: nil)

    }
    
    func setup(loadingManager: LoadingManager, coordinator: Coordinator, fireblocksManager: FireblocksManager) {
        self.loadingManager = loadingManager
        self.fireblocksManager = fireblocksManager
        self.coordinator = coordinator
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismiss() {
        FireblocksManager.shared.stopJoinWallet()
    }
    
    func setURL() -> String? {
        guard let email else { return nil }
        let joinData = JoinRequestData(requestId: requestId, platform: "iOS", email: email)
        let encoded = joinData.toString().base64Encoded()
        return encoded
    }
    
    @MainActor
    @objc func onProvisionerFound() {
        self.timer?.invalidate()
        self.timer = nil
        self.loadingManager.setLoading(value: true)
    }
    
    @MainActor
    @objc func onAddingDevice() {
        self.timer?.invalidate()
        self.timer = nil
        self.loadingManager.setLoading(value: false)
    }
    
    func startTimer() {
        UsersLocalStorageManager.shared.setAddDeviceTimer()
    }
    
    func isExpired() -> Bool {
        guard let startedTime = UsersLocalStorageManager.shared.getAddDeviceTimer() else { return true }
        return Date().timeIntervalSince1970 - startedTime >= expiredInterval
    }
    
    func timeLeft() -> String {
        guard let startedTime = UsersLocalStorageManager.shared.getAddDeviceTimer() else { return "" }
        let totalSecondsLeft = Int(expiredInterval) - (Int((Date().timeIntervalSince1970 - startedTime)))
        let minutes = totalSecondsLeft / 60
        let seconds = totalSecondsLeft % 60
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    func didQRTimeExpired() {
        let vm = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, subTitle: LocalizableStrings.addDeviceFailedSubtitle, buttonTitle: LocalizableStrings.tryAgain, actionButton:  {
            self.coordinator.path = NavigationPath()
            self.coordinator.path.append(NavigationTypes.signIn(SignInViewModel.shared))
            self.coordinator.path.append(NavigationTypes.joinOrRecover)
            self.coordinator.path.append(NavigationTypes.addDevice)
        }, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
            FireblocksManager.shared.signOut()
        }, didFail: true)
        self.coordinator.path.append(NavigationTypes.feedback(vm))
    }

}
