//
//  Web3DataModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 28/02/2025.
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

struct Web3DataModel: Identifiable, Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id = UUID().uuidString
    var accountId: Int = 0
    var connections: [Web3Connection] = []
    var connection: Web3Connection?
    var uri: String = ""
    var response: CreateWeb3ConnectionResponse?
    
    static func mock() -> Web3DataModel {
        var model = Web3DataModel()
        if let data = Mocks.Connections.getResponse.data(using: .utf8) {
            if let connections: PaginatedResponse<Web3Connection> = try? GenericDecoder.decode(data: data) {
                model.connections = connections.data ?? []
                model.connection = model.connections.first
            }
        }

        if let data = Mocks.Connections.create.data(using: .utf8) {
            if let response: CreateWeb3ConnectionResponse = try? GenericDecoder.decode(data: data) {
                model.response = response
            }
        }

        model.uri = "0xd27429aB6c46aFA34f09b7831882c180D55831E2"
        return model
    }
}
