//
//  E3WebConnectionRowViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 25/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

extension E3WebConnectionRow {
    @Observable
    class ViewModel {
        var image: Image?
        let connection: Web3Connection
        init(connection: Web3Connection) {
            self.connection = connection
            
            if let imageURL = connection.sessionMetadata?.appIcon, let url = URL(string: imageURL) {
                Task {
                    if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                        await MainActor.run {
                            self.image = Image(uiImage: uiimage)
                        }
                    }
                }
            }
        }
        
    }
}
