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
        var uiimage: UIImage?
        var image: Image?
        let connection: Web3Connection
        init(connection: Web3Connection) {
            self.connection = connection
            
            if let imageURL = connection.sessionMetadata?.appIcon, let url = URL(string: imageURL) {
                Task {
                    if let data = try? Data(contentsOf: url) {
                        if let uiimage = UIImage(data: data) {
                            await MainActor.run {
                                self.uiimage = uiimage
                                self.image = Image(uiImage: uiimage)
                            }
                        }
                    }
                }
            }
        }
        
    }
}
