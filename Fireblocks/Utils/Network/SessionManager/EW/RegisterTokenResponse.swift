//
//  RegisterTokenResponse.swift
//  Fireblocks
//
//  Created by Ofir Barzilay  on 04/06/2025.
//

struct RegisterTokenResponse: Codable {
    let success: Bool?
    let data: RegisterTokenResponseData?
}

struct RegisterTokenResponseData: Codable {
    let id: String?
    let userId: String?
    let platform: String?
    let walletId: String?
    let deviceId: String?
}
