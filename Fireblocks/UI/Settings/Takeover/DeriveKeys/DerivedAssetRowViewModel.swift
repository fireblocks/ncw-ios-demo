//
//  SymbolViewModel.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI

extension DerivedAssetRow {
    @Observable
    class ViewModel {
        var assetImage: Image?
        
        init(symbol: String?, iconUrl: String?) {
            guard let symbol = symbol else {
                return
            }
            loadAssetImage(symbol: symbol, iconUrl: iconUrl)
        }
        
        func loadAssetImage(symbol: String, iconUrl: String?) {
            Task {
                if let uiImage = await AssetImageLoader.shared.loadAssetImage(symbol: symbol, iconUrl: iconUrl) {
                    await MainActor.run {
                        self.assetImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}
