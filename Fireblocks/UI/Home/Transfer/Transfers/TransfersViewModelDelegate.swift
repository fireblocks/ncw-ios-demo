//
//  TransfersViewModelDelegate.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation
import UIKit.UIImage

protocol TransfersViewModelDelegate: AnyObject {
    func transfersUpdated()
    func showNotification(type: NotificationType)
}