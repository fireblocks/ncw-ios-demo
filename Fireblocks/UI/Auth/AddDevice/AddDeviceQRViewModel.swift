//
//  AddDeviceQRViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import Foundation

class AddDeviceQRViewModel: ObservableObject {
    let requestId: String
    var email: String?
    let expiredInterval: TimeInterval = 180.seconds
    var timer: Timer?
    @Published var timeleft = ""
    @Published var isToolbarHidden = false

    init(requestId: String, email: String?) {
        self.requestId = requestId
        self.email = email
        self.startTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if let self {
                if self.isExpired() {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.timeleft = ""
                } else {
                    self.timeleft = self.timeLeft()
                }
            }
        }
        timer?.fire()
    }
    
    var url: String? {
        guard let email else { return nil }
        let joinData = JoinRequestData(requestId: requestId, platform: "iOS", email: email)
        let encoded = joinData.toString().base64Encoded()
        return encoded
    }
    
    func qrData(encoded: String) -> JoinRequestData? {
        if let data = encoded.data(using: .utf8) {
            let decoder = JSONDecoder()
            return try? decoder.decode(JoinRequestData.self, from: data)
        }
        return nil
    }
    
    func showIndicator() {
        isToolbarHidden = true
        NotificationCenter.default.post(name: Notification.Name("showIndicator"), object: nil, userInfo: nil)
    }
    
    func showToast() {
        NotificationCenter.default.post(name: Notification.Name("copied"), object: nil, userInfo: nil)
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
}
