//
//  VersionBanner.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 20/12/2023.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    var displayName: String {
        return infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }

    
    var versionLabel: String {
        return "Version " + releaseVersionNumber + " • " + "Build " + buildVersionNumber + " • " + displayName + " • " + EnvironmentConstants.env.rawValue.capitalized
    }
}


