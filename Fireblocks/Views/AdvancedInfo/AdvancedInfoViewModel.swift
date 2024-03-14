//
//  AdvancedInfoViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation
import FireblocksSDK

extension AdvancedInfoView {
    class ViewModel: ObservableObject {
        private var mpcKeys: [KeyDescriptor] = FireblocksManager.shared.getMpcKeys()
        
        func getMpcKeys() -> [KeyDescriptor] {
            return mpcKeys
        }
        
        func getWalletId() -> String {
            return FireblocksManager.shared.getWalletId()
        }

        func getDeviceId() -> String {
            return FireblocksManager.shared.getDeviceId()
        }

    }
}
