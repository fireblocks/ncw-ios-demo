//
//  Transfer.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import Foundation
import UIKit.UIImage

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
    var status: TransferStatusType
    let transactionHash: String
    let price: Double
    let blockChainName: String
    let senderWalletId: String
    let receiverWalletID: String
    let image: UIImage
    
    func getPriceString() -> String {
        return "$\(price)"
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
    
    func toTransaction() -> Transaction? {
        if let asset = AssetListViewModel.shared.getAsset(by: assetId) {
            return Transaction(asset: asset, amountToSend: amount, price: price, receiverAddress: receiverAddress, txId: transactionID, isTransferred: true, transferFee: fee)
        }
        return nil

    }
    
    mutating func updateStatusWhenApproved() {
        self.status = .Queued
    }
}
