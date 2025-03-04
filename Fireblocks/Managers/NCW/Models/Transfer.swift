//
//  Transfer.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import Foundation
import SwiftUI
import UIKit.UIImage
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct TransferInfo {
    let transactionID: String
    let creationDate: String
    let lastUpdated: TimeInterval?
    var assetId: String
    let assetSymbol: String
    let amount: Double
    let fee: Double
    let receiverAddress: String
    let sourceAddress: String
    var status: Status
    let transactionHash: String
    let price: Double
    let blockChainName: String
    let senderWalletId: String
    let receiverWalletID: String
    let image: UIImage
    
    var color: UIColor {
        switch status {
        case .confirming, .broadcasting, .pendingSignature, .pendingAuthorization, .queued:
            return (AssetsColors.inProgress.getColor())
        case .completed, .submitted:
            return (AssetsColors.success.getColor())
        case .failed, .blocked, .cancelled, .rejected:
            return (AssetsColors.alert.getColor())
        default:
            return (AssetsColors.white.getColor())
        }
    }
    
    func getColor() -> Color {
        return Color(uiColor: color)
    }
    
    var getStatusString: String {
        return status.rawValue.replacingOccurrences(of: "_", with: " ").lowercased().capitalized()
    }

    #if EW
    static func toTransferInfo(response: TransactionResponse) -> TransferInfo {
        let statusType = response.status ?? .unknown
        let image = AssetsImageMapper().getIconForAsset(response.assetId ?? "")
        return TransferInfo(transactionID: response.id ?? "",
                            creationDate: response.createdAt?.toDateFormattedString() ?? "",
                            lastUpdated:  TimeInterval(response.lastUpdated ?? 0),
                            assetId: response.assetId ?? "",
                            assetSymbol: response.assetId ?? "",
                            amount: Double(response.amountInfo?.amount ?? "0")?.formatFractions(fractionDigits: 6) ?? 0,
                            fee: Double(response.feeInfo?.networkFee ?? "0") ?? 0,
                            receiverAddress: response.destinationAddress ?? "",
                            sourceAddress: response.sourceAddress ?? "",
                            status: statusType,
                            transactionHash: response.txHash ?? " ",
                            price: Double(response.amountInfo?.amountUSD ?? "0")?.formatFractions(fractionDigits: 6) ?? 0,
                            blockChainName: response.feeCurrency ?? "",
                            senderWalletId: response.source?.walletId ?? "",
                            receiverWalletID: response.destination?.walletId ?? "",
                            image: image)

    }
    #else
    static func toTransferInfo(response: TransactionResponse) -> TransferInfo {
        var statusType: Status = .unknown
        if let status = response.details.status {
            statusType = Status(rawValue: status.rawValue) ?? .unknown
        }
        
        let image = AssetsImageMapper().getIconForAsset(response.details.assetId ?? "")
        return TransferInfo(transactionID: response.id ,
                            creationDate: response.createdAt?.toDateFormattedString() ?? "",
                            lastUpdated:  response.lastUpdated,
                            assetId: response.details.assetId ?? "",
                            assetSymbol: response.details.assetId ?? "",
                            amount: Double(response.details.amountInfo?.amount ?? "0")?.formatFractions(fractionDigits: 6) ?? 0,
                            fee: response.details.networkFee ?? 0,
                            receiverAddress: response.details.destinationAddress ?? "",
                            sourceAddress: response.details.sourceAddress ?? "",
                            status: statusType,
                            transactionHash: response.details.txHash ?? " ",
                            price: Double(response.details.amountInfo?.amountUSD ?? "0")?.formatFractions(fractionDigits: 6) ?? 0,
                            blockChainName: response.details.feeCurrency ?? "",
                            senderWalletId: response.details.source?.walletId ?? "",
                            receiverWalletID: response.details.destination?.walletId ?? "",
                            image: image)

    }
    #endif
    
    func getPriceString() -> String {
        return "$\(price.formatFractions(fractionDigits: 6))"
    }
    
    func getReceiverTitle(walletId: String) -> String {
        if senderWalletId == walletId {
            return "Sent to"
        } else {
            return "Received from"
        }
    }

    func getReceiverAddress(walletId: String) -> String {
        if senderWalletId == walletId {
            return receiverAddress
        } else {
            return sourceAddress
        }
    }

    func getTransferTitle(walletId: String) -> String {
        if senderWalletId == walletId {
            return "Send \(assetSymbol)"
        } else {
            return "Receive \(assetSymbol)"
        }
    }
    
    func getTxHash() -> String {
        return transactionHash.isEmpty ? "-" : transactionHash
    }
    
    func isTxHashEmpty() -> Bool {
        return transactionHash.isEmpty
    }
    
    func toTransaction(assetListViewModel: AssetListViewModel) -> FBTransaction? {
        if let asset = assetListViewModel.getAsset(by: assetId) {
            return FBTransaction(asset: AssetSummary(asset: asset), amountToSend: amount, price: price, receiverAddress: receiverAddress, txId: transactionID, isTransferred: true, transferFee: fee)
        }
        return nil

    }
    
    mutating func updateStatusWhenApproved() {
        self.status = .queued
    }
}
