//
//  Fee.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class FeeManager {
    static func calcFee(feeResponse: EstimatedTransactionFeeResponse) -> [Fee] {
        var feeArray: [Fee] = []
        if let feeData = feeResponse.low, let fee = feeData.networkFee {
            feeArray.append(Fee(feeRateType: .low, fee: "\(fee)"))
        }
        if let feeData = feeResponse.medium, let fee = feeData.networkFee {
            feeArray.append(Fee(feeRateType: .medium, fee: "\(fee)"))
        }
        if let feeData = feeResponse.high, let fee = feeData.networkFee {
            feeArray.append(Fee(feeRateType: .high, fee: "\(fee)"))
        }

        return feeArray
    }

}





