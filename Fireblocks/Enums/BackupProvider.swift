//
//  BackupProvider.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/07/2023.
//

import Foundation

enum BackupProvider: CaseIterable {
    case iCloud, googleDrive, external
    
    func getValue() -> String {
        switch self {
        case .iCloud:
            return LocalizableStrings.iCloud
        case .googleDrive:
            return LocalizableStrings.googleDrive
        case .external:
            return LocalizableStrings.externalLocation
        }
    }
}
