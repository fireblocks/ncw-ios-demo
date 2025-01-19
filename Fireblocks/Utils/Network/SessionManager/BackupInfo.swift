//
//  BackupInfo.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//


struct BackupInfo: Codable {
    var passphraseId: String?
    var deviceId: String?
    var location: BackupProvider?
    var createdAt: Int?
}
