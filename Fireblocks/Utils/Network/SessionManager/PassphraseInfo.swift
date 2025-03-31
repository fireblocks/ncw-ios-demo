//
//  PassphraseInfo.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//


struct PassphraseInfo: Codable {
    let passphraseId: String
    let location: BackupProvider
}

struct PassphraseInfos: Codable {
    let passphrases: [PassphraseInfo]
}

