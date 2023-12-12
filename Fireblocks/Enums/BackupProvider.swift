//
//  BackupProvider.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/07/2023.
//

import Foundation

enum BackupProvider: String, CaseIterable, Codable {
    case iCloud
    case GoogleDrive
    case external
    
    func title() -> String {
        switch self {
        case .iCloud:
            return "iCloud"
        case .GoogleDrive:
            return "Google Drive"
        case .external:
            return "External"
        }
    }
}
