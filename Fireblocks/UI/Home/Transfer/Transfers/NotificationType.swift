//
//  NotificationType.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation
import UIKit.UIImage

enum NotificationType {
    case notification
    case error
    
    func getImage() -> UIImage {
        switch self {
        case .notification:
            return AssetsIcons.transferImage.getIcon()
        case .error:
            return AssetsIcons.errorImage.getIcon()
        }
    }
    
    func getMessage() -> String {
        switch self {
        case .notification:
            return "You don’t have any transfers yet."
        case .error:
            return "failed to load transactions,\n please try to refresh."
        }
    }
    
    func isRefreshButtonNeeded() -> Bool {
        switch self {
        case .notification:
            return false
        case .error:
            return true
        }
    }
}