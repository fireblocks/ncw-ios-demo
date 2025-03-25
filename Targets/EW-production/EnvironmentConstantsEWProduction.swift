//
//  EnvironmentConstantsEWSandbox.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 13/03/2025.
//

import Foundation
import FireblocksSDK
import EmbeddedWalletSDK

struct EnvironmentConstants {
    static let baseURL = "https://sb-ncw.fireblocks.io"
    static let env: FireblocksEnvironment = .production
    static let ewEnv: EmbeddedWalletEnvironment = .PRODUCTION
    static let authClientId = "80d145cf-7b5f-42d5-9923-5364bc6c5140"

}
