//
//  EnvironmentConstantsProd.swift
//  NCW-production
//
//  Created by Dudi Shani-Gabay on 09/04/2024.
//

import Foundation
import FireblocksSDK

struct EnvironmentConstants {
    static let baseURL = "https://api-prod.ncw-demo.com"
    static let env: FireblocksSDK.FireblocksEnvironment = .production
}
