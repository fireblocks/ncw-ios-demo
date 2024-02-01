//
//  RedirectNewUserViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 25/01/2024.
//

import Foundation

protocol RedirectNewUserDelegate: AnyObject {
    func signOut()
    func recoverTapped()
}

extension RedirectNewUserView {
    class ViewModel: ObservableObject, UIHostingBridgeNotifications {
        var didAppear: Bool = false
        weak var delegate: RedirectNewUserDelegate?
        
        func signOut() {
            self.delegate?.signOut()
        }
        
        func addDeviceTapped() {
            self.delegate?.signOut()
        }
        
        func recoverTapped() {
            self.delegate?.recoverTapped()
        }
    }
}
