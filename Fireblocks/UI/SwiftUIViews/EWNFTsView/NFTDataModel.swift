//
//  NFTDataModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//
import SwiftUI
import UIKit

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct NFTDataModel: Identifiable, Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID().uuidString
    var tokens: [TokenOwnershipResponse] = []
    var token: TokenOwnershipResponse?
    var address: String = ""
    var feeLevel: FeeLevel = .LOW
    var transaction: CreateTransactionResponse?
    
    static func mock() -> NFTDataModel {
        var model = NFTDataModel()
        if let data = Mocks.NFT.getOwnedResponse.data(using: .utf8) {
            if let nfts: PaginatedResponse<TokenOwnershipResponse> = try? GenericDecoder.decode(data: data) {
                model.tokens = nfts.data ?? []
                model.token = model.tokens.first
            }
        }
        model.address = "0xd27429aB6c46aFA34f09b7831882c180D55831E2"
        model.feeLevel = .MEDIUM
        if let data = Mocks.Transaction.createTransactionResponse.data(using: .utf8) {
            if let transaction: CreateTransactionResponse = try? GenericDecoder.decode(data: data) {
                model.transaction = transaction
            }
        }

        return model
    }
}
