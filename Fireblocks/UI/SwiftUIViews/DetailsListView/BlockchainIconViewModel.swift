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
                let blockchainImageURL: String? = SessionManager.shared.constructImageURL(iconUrl: nil, symbol: blockchainSymbol)
                if let blockchainImageURL = blockchainImageURL, let url = URL(string: blockchainImageURL) {
                    if let blockchainUIImage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.blockchainImage = Image(uiImage: blockchainUIImage)
                        }
                    }
                }
            }
        }
    }
}
