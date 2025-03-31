//
//  BackupData.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

import Foundation

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
        self.location = backupInfo.location?.rawValue
        self.date = backupInfo.createdAt != nil ? "\(Date(timeIntervalSince1970: TimeInterval(backupInfo.createdAt!)/1000).format())" : nil
        self.title = backupInfo.location?.title()
    }
}
