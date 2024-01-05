//
//  ValidateRequestIdViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
class ValidateRequestIdViewModel: ObservableObject, UIHostingBridgeNotifications {
    var didAppear: Bool = false
    let requestId: String
    var email: String?
    var platform: String?
    
    let expiredInterval: TimeInterval = 180.seconds
    var timer: Timer?
    @Published var timeleft = ""
    @Published var isToolbarHidden = false
    
    init(requestId: String) {
        self.requestId = requestId
        if let decoded = self.qrData(encoded: requestId.base64Decoded() ?? "") {
            self.email = decoded.email
            self.platform = decoded.platform
            
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
    

    func presentIndicator() {
        isToolbarHidden = true
        showIndicator()
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
