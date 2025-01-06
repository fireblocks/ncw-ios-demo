//
//  EWManager.swift
//  NCW-dev
//
//  Created by Dudi Shani-Gabay on 07/10/2024.
//

import Foundation
//import EmbeddedWalletSDKDev
//
//class EWManager {
//    let authClientId = "6303105e-38ac-4a21-8909-2b1f7f205fd1"
//    var token: String = ""
//    
//    let options = EmbeddedWalletOptions(env: .RENTBLOCKS, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
//    
//    func initialize(token: String) -> EmbeddedWallet? {
//        self.token = token
//        let instance = try? EmbeddedWallet.initialize(authTokenRetriever: self, authClientId: authClientId, embeddedWalletOptions: EmbeddedWalletOptions())
//        return instance
//
//    }
//
//}
//
//extension EWManager: AuthTokenRetriever {
//    func getAuthToken() async -> Result<String, any Error> {
//        return .success(token)
//    }
//}
