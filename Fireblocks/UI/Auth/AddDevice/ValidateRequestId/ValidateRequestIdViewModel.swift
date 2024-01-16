//
//  ValidateRequestIdViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
import FireblocksSDK

protocol ValidateRequestIdDelegate: AnyObject {
    func didApproveJoinWallet()
    func didCancelJoinWallet()
    func didApproveJoinWalletTimeExpired()
}

class ValidateRequestIdViewModel: ObservableObject, UIHostingBridgeNotifications {
    var didAppear: Bool = false
    var requestId: String?
    weak var delegate: ValidateRequestIdDelegate?
    var email: String?
    var platform: String?
    private var approveJoinWalletTask: Task<Void, Never>?

    let expiredInterval: TimeInterval = 10.seconds
    var timer: Timer?
    @Published var timeleft = ""
    @Published var isToolbarHidden = false
    @Published var error: String?
    
    init(requestId: String) {
        if let decoded = self.qrData(encoded: requestId.base64Decoded() ?? "") {
            self.email = decoded.email
            self.platform = decoded.platform
            self.requestId = decoded.requestId

            self.startTimer()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                if let self {
                    if self.isExpired() {
                        self.timer?.invalidate()
                        self.timer = nil
                        self.timeleft = ""
                        self.delegate?.didApproveJoinWalletTimeExpired()
                    } else {
                        self.timeleft = self.timeLeft()
                    }
                }
            }
            timer?.fire()
        } else {
            //handle error
        }

    }
    
    private func qrData(encoded: String) -> JoinRequestData? {
        if let data = encoded.data(using: .utf8) {
            let decoder = JSONDecoder()
            return try? decoder.decode(JoinRequestData.self, from: data)
        }
        return nil
    }
    

    func presentIndicator(show: Bool) {
        isToolbarHidden = show
        if show {
            showIndicator()
        } else {
            hideIndicator()
        }
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
    
    func approveJoinWallet() {
        guard let requestId else { return }
        presentIndicator(show: true)
        approveJoinWalletTask = Task {
            do {
                let keys = try await FireblocksManager.shared.approveJoinWallet(requestId: requestId)
                DispatchQueue.main.async {
                    self.presentIndicator(show: false)
                    if let _ = keys.first(where: {$0.status == .ERROR}) {
                        self.error = LocalizableStrings.approveJoinWalletFailed
                        return
                    }
                    self.delegate?.didApproveJoinWallet()
                }
            } catch {
                DispatchQueue.main.async {
                    self.presentIndicator(show: false)
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    func didTapCancel() {
        self.timer?.invalidate()
        self.timer = nil
        delegate?.didCancelJoinWallet()
    }
}
