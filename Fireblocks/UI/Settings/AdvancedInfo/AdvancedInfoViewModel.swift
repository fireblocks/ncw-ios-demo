//
//  AdvancedInfoViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 18/07/2023.
//

import Foundation
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

final class AdvancedInfoViewModel {
    
    private var mpcKeys: [KeyDescriptor]
    
    init() {
        do {
            self.mpcKeys = try FireblocksManager.shared.getMpcKeys()
        } catch {
            self.mpcKeys = []
        }
    }
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
