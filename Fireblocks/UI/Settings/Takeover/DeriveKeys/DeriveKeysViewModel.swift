//
//  DeriveKeysViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 06/03/2024.
//

import Foundation
import UIKit
import FireblocksDev

extension DeriveKeysView {
    
    class ViewModel: ObservableObject {
        let privateKey: String
        @Published var selectedAsset: Asset?
        @Published var items: [DerivedKeyItem]
        
        var title: String = "Copy the Private Keys and save them in a secure location. You are now the responsible for their security."
        var navigationBarTitle: String = LocalizableStrings.exportPrivateKeyTitle
        
        init(privateKey: String) {
            self.privateKey = privateKey
            self.items = AssetListViewModel.shared.getAssetSummary().map({DerivedKeyItem(assetSummary: $0)})
            Task {
                await generateKeys()
            }
        }
        
        func generateKeys() async {
            for i in 0..<items.count {
                let data = await items[i].deriveAssetKey(privateKey: privateKey)
                let wif = items[i].getWif(privateKey: data?.data)
                DispatchQueue.main.async {
                    self.items[i].keyData = data
                    self.items[i].wif = wif
                }
            }
        }
    }
    
}
