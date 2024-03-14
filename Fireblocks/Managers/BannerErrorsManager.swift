//
//  BannerErrorsManager.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation

class BannerErrorsManager: ObservableObject {
    @Published var toastMessage: String? {
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
