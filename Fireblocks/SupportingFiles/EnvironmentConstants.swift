//
//  Environment.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 04/07/2023.
//

import Foundation
import FireblocksSDK

struct EnvironmentConstants {
    static let baseURL = "https://ncw-demo-dev.2uaqu5aka49io.eu-central-1.cs.amazonlightsail.com"
    static let env: FireblocksSDK.FireblocksEnvironment = .sandbox
}

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    var versionLabel: String {
        return "Version " + releaseVersionNumber + " • " + "Build " + buildVersionNumber + " • " + EnvironmentConstants.env.rawValue.capitalized
    }
}


