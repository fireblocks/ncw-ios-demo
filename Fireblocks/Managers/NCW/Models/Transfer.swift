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

struct TransferInfo: Identifiable, Equatable, Hashable {
    static func == (lhs: TransferInfo, rhs: TransferInfo) -> Bool {
        return lhs.id == rhs.id && lhs.lastUpdated == rhs.lastUpdated && lhs.status == rhs.status
    }

    var id: String {
        return transactionID
    }
    
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
//    let image: UIImage
    var nftWrapper: NFTWrapper?
    
    var color: UIColor {
        return TransferUtils.getStatusColor(status: status)
    }

    
    func getColor() -> Color {
        return Color(uiColor: color)
    }
    
    var getStatusString: String {
        return status.rawValue.beautifySigningStatus()
    }
    


    #if EW
    static func toTransferInfo(response: TransactionResponse) -> TransferInfo {
        let statusType = response.status ?? .unknown
//        let image = AssetsImageMapper().getIconForAsset(response.assetId ?? "")
        let assetId = response.assetId?.hasPrefix("NFT") == true ? response.feeCurrency ?? "" : response.assetId ?? ""
        return TransferInfo(transactionID: response.id ?? "",
                            creationDate: response.createdAt?.toDateFormattedString() ?? "",
                            lastUpdated:  TimeInterval(response.lastUpdated ?? 0),
                            assetId: response.assetId ?? "",
                            assetSymbol: response.assetId?.hasPrefix("NFT") == true ? response.feeCurrency ?? "" : response.assetId ?? "", //TODO: find a better way to get the blockchain in caseof NFT
                            amount: Double(response.amountInfo?.amount ?? "0")?.formatFractions(fractionDigits: 6) ?? 0,
                            fee: Double(response.feeInfo?.networkFee ?? "0") ?? 0,
                            receiverAddress: response.destinationAddress ?? "",
                            sourceAddress: response.sourceAddress ?? "",
                            status: statusType,
                            transactionHash: response.txHash ?? " ",
                            price: Double(response.amountInfo?.amountUSD ?? "0")?.formatFractions(fractionDigits: 6) ?? 0,
                            blockChainName: response.feeCurrency ?? "",
                            senderWalletId: response.source?.walletId ?? "",
                            receiverWalletID: response.destination?.walletId ?? "")
//                            image: image)

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
                            receiverWalletID: response.details.destination?.walletId ?? "")

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

    func getReceiverRowTitle(walletId: String) -> String {
        if senderWalletId == walletId {
            return "Sent "
        } else {
            return "Received "
        }
    }
    
    func getSendOrReceiveTitle(walletId: String) -> String {
        if senderWalletId == walletId {
            return LocalizableStrings.sent
        } else {
            return LocalizableStrings.received
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
        return transactionHash
    }
    
    func isTxHashEmpty() -> Bool {
        return transactionHash.isEmpty
    }
    
    func isNFT() -> Bool {
        return assetId.hasPrefix("NFT")
    }
    
    func toTransaction(assetListViewModel: AssetListViewModel) -> FBTransaction? {
        let assetName = isNFT() ? blockChainName : assetId
        if let asset = assetListViewModel.getAsset(by: assetName) {
            return FBTransaction(asset: AssetSummary(asset: asset), amountToSend: amount, price: price, receiverAddress: receiverAddress, txId: transactionID, isTransferred: true, transferFee: fee)
        }
        return nil

    }
    
    func isEndedTransaction() -> Bool {
        let endedTransactionStatusArray: [Status] = [
            .completed, .failed, .cancelled, .blocked, .rejected
        ]
        return endedTransactionStatusArray.contains(status)
    }
    
    mutating func updateStatusWhenApproved() {
        self.status = .queued
    }
}
