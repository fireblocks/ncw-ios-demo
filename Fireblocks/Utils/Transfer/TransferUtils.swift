//
//  TransferUtils.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 08/04/2025.
//
import Foundation
import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class TransferUtils {
    static func getStatusColor(status: Status) -> UIColor {
        let uiColor = switch status {
        case .confirming, .broadcasting, .pendingSignature, .pendingAuthorization, .queued:
             (AssetsColors.inProgress.getColor())
        case .completed, .submitted:
             (AssetsColors.success.getColor())
        case .failed, .blocked, .cancelled, .rejected:
             (AssetsColors.alert.getColor())
        default:
             (AssetsColors.white.getColor())
        }
        return uiColor
    }
}
