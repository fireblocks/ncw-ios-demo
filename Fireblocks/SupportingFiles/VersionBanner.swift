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
    
    
    var versionAndEnvironmentLabel: String { //TODO: align with Android and add SDKVersionsLabel
        return "Version " + releaseVersionNumber + " • " + "Build " + buildVersionNumber + " • " + displayName
    }
    
    func getSDKVersionsLabel() -> String {
        let ncwVersion = getBundleVersion(containing: "FireblocksSDK") ?? "N/A"
        
        #if EW
        let ewVersion = getBundleVersion(containing: "EmbeddedWalletSDK") ?? "N/A"
        return "EW \(ewVersion) • NCW \(ncwVersion)"
        #else
        return "NCW \(ncwVersion)"
        #endif
    }
    
    private func getBundleVersion(containing name: String) -> String? {
        // Search through all bundles and frameworks
        let allBundles = Bundle.allBundles + Bundle.allFrameworks
        
        for bundle in allBundles {
            let bundlePath = bundle.bundlePath
            let bundleIdentifier = bundle.bundleIdentifier ?? ""
            
            if bundlePath.contains(name) || bundleIdentifier.contains(name) {
                if let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String {
                    return version
                }
            }
        }
        return nil
    }
    
    
    
}
