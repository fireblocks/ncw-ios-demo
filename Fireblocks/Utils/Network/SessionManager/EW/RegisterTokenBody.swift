//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay  on 04/06/2025.
//

struct RegisterTokenBody: Codable {
    let token: String
    let platform: String
    let walletId: String
    let deviceId: String
    
    init(token: String, walletId: String, deviceId: String, platform: String = "ios") {
        self.token = token
        self.platform = platform
        self.walletId = walletId
        self.deviceId = deviceId
    }
}
