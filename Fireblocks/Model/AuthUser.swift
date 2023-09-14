//
//  AuthUser.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation

struct AuthUser: Decodable {
    var userToken: String
    let deviceId: String
    let walletId: String
//    let backup: BackupData?
}

struct BackupData: Codable {
    let isBackedUp: Bool?
    let email: String?
    let date: String?
    let location: String?
}
