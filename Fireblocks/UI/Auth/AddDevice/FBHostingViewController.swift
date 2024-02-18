//
//  FBHostingViewController.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import Foundation
import SwiftUI
import UIKit


protocol UIHostingViewDelegate: AnyObject {
    func showIndicator()
    func copied()
}

class FBHostingViewController: UIHostingController<AnyView> {
    override init(rootView: AnyView) {
        super.init(rootView: rootView)
        NotificationCenter.default.addObserver(self, selector: #selector(showIndicator), name: Notification.Name("showIndicator"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideIndicator), name: Notification.Name("hideIndicator"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(copied), name: Notification.Name("copied"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didInit), name: Notification.Name("didInit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendLogs), name: Notification.Name("sendLogs"), object: nil)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension FBHostingViewController: UIHostingViewDelegate {
    @objc func showIndicator() {
        self.showActivityIndicator()
    }
    
    @objc func hideIndicator() {
        self.hideActivityIndicator()
    }
    
    @objc func copied() {
        self.showToast("Copied!")
    }

    @objc func sendLogs() {
        self.createLogFile()
    }

    @objc func didInit() {
    }

}

