//
//  SymbolViewModel.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI

extension BlockchainIconView {
    @Observable
    class ViewModel {
        var blockchainImage: Image?
        
        init(blockchainSymbol: String?) {
            guard let blockchainSymbol = blockchainSymbol else {
                return
            }
            loadBlockchainImage(blockchainSymbol: blockchainSymbol)
        }
        
        func loadBlockchainImage(blockchainSymbol: String) {
            Task {
                if let uiImage = await AssetImageLoader.shared.loadAssetImage(symbol: blockchainSymbol, iconUrl: nil) {
                    await MainActor.run {
                        self.blockchainImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }
}
