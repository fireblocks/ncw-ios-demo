//
//  AdvancedInfoViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 18/07/2023.
//

import Foundation
import FireblocksSDK

final class AdvancedInfoViewModel {
    
    private var mpcKeys: [KeyDescriptor] = FireblocksManager.shared.getMpcKeys()
    
    func getMpcKeys() -> [KeyDescriptor] {
        return mpcKeys
    }
    
    func getDeviceId() -> String {
        return FireblocksManager.shared.getDeviceId()
    }
}
