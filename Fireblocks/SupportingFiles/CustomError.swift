//
//  CustomError.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/01/2025.
//

import Foundation

enum CustomError: LocalizedError {
    case genericError(String)
    case failedToGetInstance(String)
    case login
    case noWallet
    case assignWallet
    case deviceId
    case latestBackup
    case noAvailableBackup
    case recover
    case takeover
    case transaction
    case approveTransaction
    case cancelTransaction
    case generateKeys
    case backup
    case joinWallet
}

extension CustomError: CustomStringConvertible {
    var errorDescription: String? {
        return self.description
    }
    
    var description: String {
        switch self {
        case .genericError(let message):
            return message
        case .failedToGetInstance(let type):
            return "Failed to get \(type) instance"
        case .login:
            return "Failed to login. there is no signed in user"
        case .noWallet:
            return "Couldn't sign in. There is no existing wallet"
        case .deviceId:
            return "Failed to get device. deviceId is empty"
        case .noAvailableBackup:
            return "Could not find any available backup"
        case .latestBackup:
            return "Failed to get latest backup status"
        case .assignWallet:
            return "Failed to assign wallet"
        case .recover:
            return "Failed to recover wallet"
        case .takeover:
            return "Failed to takeover keys"
        case .transaction:
            return "Failed to get transaction"
        case .approveTransaction:
            return "Failed to approve transaction"
        case .cancelTransaction:
            return "Failed to cancel transaction"
        case .generateKeys:
            return "Failed to generate keys"
        case .backup:
            return "Failed to backup keys"
        case .joinWallet:
            return "Failed to join wallet"
        }
    }
}

