//
//  LatestBackupState.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/01/2025.
//

enum LatestBackupState {
    case generate
    case exist
    case joinOrRecover
    case error(Error)
}
