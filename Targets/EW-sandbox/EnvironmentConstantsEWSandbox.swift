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
    static let baseURL = "https://api-sb.ew-demo.net"
    static let env: FireblocksEnvironment = .sandbox
    static let ewEnv: EmbeddedWalletEnvironment = .SANDBOX
    static let authClientId = "fd8c89c8-c0fc-48b5-af74-a25d84c068d3"

}
