//
//  ValidateRequestIdViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
import SwiftUI

protocol ValidateRequestIdDelegate: AnyObject {
    func didApproveJoinWallet()
    func didCancelJoinWallet()
    func didApproveJoinWalletTimeExpired()
}

@Observable
class ValidateRequestIdViewModel {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    var fireblocksManager: FireblocksManager?
    
    var didLoad: Bool = false
    var requestId: String?
    weak var delegate: ValidateRequestIdDelegate?
    var email: String?
    var platform: String?
    private var approveJoinWalletTask: Task<Void, Never>?

    let expiredInterval: TimeInterval
    var timer: Timer?
    var timeleft = ""
    var isToolbarHidden = false
    
    init(requestId: String, expiredInterval: TimeInterval = 180.seconds) {
        self.expiredInterval = expiredInterval
        if let decoded = self.qrData(encoded: requestId.base64Decoded() ?? "") {
            self.email = decoded.email
            self.platform = decoded.platform
            self.requestId = decoded.requestId
        }

    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @MainActor
    func setup(coordinator: Coordinator, loadingManager: LoadingManager, fireblocksManager: FireblocksManager) {
        if !didLoad {
            didLoad = true
            self.coordinator = coordinator
            self.loadingManager = loadingManager
            self.fireblocksManager = fireblocksManager
            
            guard let requestId else {
                self.loadingManager?.isLoading = false
                self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
                return
            }
            
            self.startTimer()

        }

    }

    func qrData(encoded: String) -> JoinRequestData? {
        if let data = encoded.data(using: .utf8) {
            let decoder = JSONDecoder()
            return try? decoder.decode(JoinRequestData.self, from: data)
        }
        return nil
    }
    
    @MainActor
    func presentIndicator(show: Bool) {
        self.loadingManager?.isLoading = show
    }
        
    func startTimer() {
        UsersLocalStorageManager.shared.setAddDeviceTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if let self {
                if self.isExpired() {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.timeleft = ""
                    let feedbackVM = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, buttonTitle: LocalizableStrings.tryAgain, actionButton: {
                        self.startTimer()
                        self.coordinator?.path = NavigationPath()
                    }, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
                        self.coordinator?.path = NavigationPath()
                    }, didFail: true, canGoBack: false, content: AnyView(ValidateRequestIdTimeOutView()))
                    self.coordinator?.path.append(NavigationTypes.feedback(feedbackVM))

                } else {
                    self.timeleft = self.timeLeft()
                }
            }
        }
        timer?.fire()

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
    
    func approveJoinWallet() {
        guard let requestId else { return }

        self.loadingManager?.isLoading = true
        approveJoinWalletTask = Task {
            do {
                let keys = try await FireblocksManager.shared.approveJoinWallet(requestId: requestId)
                await MainActor.run {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.loadingManager?.isLoading = false
                    if let _ = keys.first(where: {$0.status == .ERROR}) {
                        self.loadingManager?.setAlertMessage(error: CustomError.genericError(LocalizableStrings.approveJoinWalletFailed))
                        return
                    }
                    let feedbackVM = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceSucceeded.rawValue, title: LocalizableStrings.approveJoinWalletSucceeded, buttonTitle: LocalizableStrings.goHome, actionButton: {
                        self.coordinator?.path = NavigationPath()
                    }, canGoBack: false)
                    self.coordinator?.path.append(NavigationTypes.feedback(feedbackVM))
                }
            } catch {
                await MainActor.run {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.loadingManager?.isLoading = false
                    try? self.fireblocksManager?.stopJoinWallet()
                    self.loadingManager?.setAlertMessage(error: error)
                }
            }
        }
    }
        
    func didTapCancel() {
        self.timer?.invalidate()
        self.timer = nil
        try? self.fireblocksManager?.stopJoinWallet()
        let feedbackVM = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceFailed.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, subTitle: LocalizableStrings.approveJoinWalletCanceledSubtitle, buttonTitle: LocalizableStrings.goHome, actionButton: {
            self.coordinator?.path = NavigationPath()
        }, didFail: true, canGoBack: false)
        self.coordinator?.path.append(NavigationTypes.feedback(feedbackVM))

    }
}
