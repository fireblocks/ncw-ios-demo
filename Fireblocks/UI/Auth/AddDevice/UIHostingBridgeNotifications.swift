//
//  UIHostingBridgeNotifications.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import Foundation

protocol UIHostingBridgeNotifications: AnyObject {
    var didAppear: Bool { get set }
    func showIndicator()
    func hideIndicator()
    func showToast()
    func didInit()
}

extension UIHostingBridgeNotifications {
    var didAppear: Bool { return false }
    func showIndicator() {
        NotificationCenter.default.post(name: Notification.Name("showIndicator"), object: nil, userInfo: nil)
    }

    func hideIndicator() {
        NotificationCenter.default.post(name: Notification.Name("hideIndicator"), object: nil, userInfo: nil)
    }
    
    func showToast() {
        NotificationCenter.default.post(name: Notification.Name("copied"), object: nil, userInfo: nil)
    }
    
    func didInit() {
        if !didAppear {
            didAppear = true
            NotificationCenter.default.post(name: Notification.Name("didInit"), object: nil, userInfo: nil)
        }
    }

}

