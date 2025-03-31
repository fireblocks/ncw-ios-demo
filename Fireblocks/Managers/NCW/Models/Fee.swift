//
//  Fee.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//


import Foundation
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct Fee {
    let feeRateType: FeeLevel
    let fee: String
    
    func getFeeName() -> String {
        return feeRateType.rawValue.lowercased().capitalized()
    }
}
