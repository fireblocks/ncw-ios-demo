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
    var date: String?
    let location: String?
    let title: String?
    
    init(isBackedUp: Bool?, date: String?, location: String?, title: String?) {
        self.isBackedUp = isBackedUp
        self.date = date
        self.location = location
        self.title = title
    }
    
    init(backupInfo: BackupInfo) {
        self.isBackedUp = true
        self.location = backupInfo.location.rawValue
        self.date = "\(Date(timeIntervalSince1970: TimeInterval(backupInfo.createdAt)/1000).format())"
        self.title = backupInfo.location.title()
    }
}
