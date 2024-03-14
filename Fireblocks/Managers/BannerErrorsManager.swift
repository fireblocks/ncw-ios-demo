//
//  BannerErrorsManager.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation

struct ToastItem {
    var icon: String?
    var message: String?
}
class BannerErrorsManager: ObservableObject {
    @Published var toastMessage: ToastItem? {
        didSet {
            if toastMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.toastMessage = nil
                }
            }
        }
    }

    @Published var errorMessage: String? {
        didSet {
            if errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.errorMessage = nil
                }
            }
        }
    }
}
