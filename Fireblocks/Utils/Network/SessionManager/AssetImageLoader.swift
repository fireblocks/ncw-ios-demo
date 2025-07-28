//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 16/04/2025.
//

import Foundation
import UIKit

import SwiftUI

class AssetImageLoader {
    static let shared = AssetImageLoader()
    
    private init() {}
    
    func loadAssetImage(symbol: String, iconUrl: String?, isBlockchain: Bool = false) async -> UIImage? {
        let urls = constructImageURLs(iconUrl: iconUrl, symbol: symbol)

        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            do {
                let image = try await SessionManager.shared.loadImage(url: url)
                return image
            } catch {
                print("Failed to load image from \(url): \(error)")
                continue
            }
        }
        
        let rawSymbol = symbol.replacingOccurrences(of: "(?:_?TEST\\d*$)|(?:TEST\\d*$)", with: "", options: .regularExpression).lowercased()
        let baseNetwork = rawSymbol.contains("_") ? rawSymbol.split(separator: "_").first.map(String.init) ?? rawSymbol : rawSymbol

        return fallbackIconImage(symbol: baseNetwork, isBlockchain: isBlockchain)
    }

    
    func loadAssetIcon(
        into imageView: UIImageView,
        iconUrl: String?,
        symbol: String,
        isBlockchain: Bool = false
    ) {
        let urls = constructImageURLs(iconUrl: iconUrl, symbol: symbol)
        guard !urls.isEmpty else {
            imageView.image = fallbackIconImage(symbol: symbol, isBlockchain: isBlockchain)
            return
        }
        
        let placeholder = AssetsImageMapper().getPlaceHolderImage(assetSign: symbol, isBlockchain: isBlockchain)

        var remainingURLs = urls

        func attemptLoad(from urlString: String) {
            guard let url = URL(string: urlString) else {
                tryNextURL()
                return
            }

            imageView.sd_setImage(with: url, placeholderImage: placeholder, options: [], completed: { image, error, _, _ in
                if image != nil {
                    imageView.image = image
                } else {
                    tryNextURL()
                }
            })
        }

        func tryNextURL() {
            remainingURLs.removeFirst()
            if let next = remainingURLs.first {
                attemptLoad(from: next)
            } else {
                imageView.image = fallbackIconImage(symbol: symbol, isBlockchain: isBlockchain)
            }
        }

        attemptLoad(from: remainingURLs.first!)
    }
    
    func getFormattedSymbol(assetId: String) -> String {
        let formattedSymbol = assetId.replacingOccurrences(of: "(?:_?TEST\\d*$)|(?:TEST\\d*$)", with: "", options: .regularExpression)
        return formattedSymbol
    }


    func constructImageURLs(iconUrl: String?, symbol: String) -> [String] {
        if symbol.isEmpty {
            return []
        }
        let rawSymbol = symbol.replacingOccurrences(of: "(?:_?TEST\\d*$)|(?:TEST\\d*$)", with: "", options: .regularExpression).lowercased()
        let baseNetwork = rawSymbol.contains("_") ? rawSymbol.split(separator: "_").first.map(String.init) ?? rawSymbol : rawSymbol

        let normalizedSymbol = normalizeSymbol(symbol: rawSymbol)
        let normalizedBaseNetwork = normalizeSymbol(symbol: baseNetwork)
        
        var array = [String]()
        if let iconUrl = iconUrl {
            array.append(iconUrl)
        } else {
            if (baseNetwork == "basechain" || baseNetwork == "etherlink"){
                return []
            }
        }
        array.append("https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/color/\(normalizedSymbol).png")
        array.append("https://assets.coincap.io/assets/icons/\(normalizedBaseNetwork)@2x.png")
        if normalizedSymbol != normalizedBaseNetwork {
            array.append("https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/color/\(normalizedBaseNetwork).png")
            array.append("https://assets.coincap.io/assets/icons/\(normalizedSymbol)@2x.png")
        }
        
        return array

//        return [
//            iconUrl,
//            "https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/color/\(normalizedBaseNetwork).png",
//            normalizedSymbol != normalizedBaseNetwork ? "https://raw.githubusercontent.com/spothq/cryptocurrency-icons/master/32/color/\(normalizedSymbol).png" : nil,
//            "https://assets.coincap.io/assets/icons/\(normalizedBaseNetwork)@2x.png",
//            normalizedSymbol != normalizedBaseNetwork ? "https://assets.coincap.io/assets/icons/\(normalizedSymbol)@2x.png" : nil,
////                "https://cryptoicons.org/api/\(normalizedSymbol)/200",
////                "https://cryptologos.cc/logos/\(normalizedSymbol)-\(normalizedSymbol)-logo.png",
////                "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/32/color/\(normalizedSymbol).png",
////                "https://cdn.jsdelivr.net/gh/atomiclabs/cryptocurrency-icons@master/32/color/\(normalizedBaseNetwork).png"
//        ]
    }

    private func normalizeSymbol(symbol: String) -> String {
        switch symbol {
        case "bsc": return "bnb"
        case "avalanche", "avalanche_fuji": return "avax"
        case "polygon", "amoy", "amoy_polygon": return "matic"
        case "arbitrum", "arbitrum_rin": return "arb"
        case "optimistic", "opt", "optimistic_kov": return "op"
        case "algo_usdc": return "algo"
        case "mantra": return "om"
        default: return symbol
        }
    }

    private func fallbackIconImage(symbol: String, isBlockchain: Bool) -> UIImage {
        let localImage = AssetsImageMapper().getIconForAsset(symbol)
        return localImage ?? AssetsImageMapper().getPlaceHolderImage(assetSign: symbol, isBlockchain: isBlockchain)
    }
}
    
