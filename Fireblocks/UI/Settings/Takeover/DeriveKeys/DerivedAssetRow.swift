//
//  DerivedAssetRow.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 06/03/2024.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct DerivedAssetRow: View {
    let asset: AssetSummary
    @State var viewModel: ViewModel
    
    init(asset: AssetSummary) {
        self.asset = asset
        _viewModel = State(initialValue: ViewModel(symbol: asset.asset?.symbol, iconUrl: asset.iconUrl))
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                if let assetImage = viewModel.assetImage {
                    Group {
                        assetImage
                    }
                    .padding(4)
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))

            if let name = asset.asset?.name {
                Text(name)
                    .font(.b1)
                    .multilineTextAlignment(.leading)
            }

        }
    }
}

#Preview {
    #if EW
    let asset: Asset = Asset(id: "1", symbol: "BTC", name: "Bitcoin", blockchain: "BTC")
    let jsonString = """
    {
        "id": "xxxxx",
        "total": "0.0001",
        "available": "0.0001",
        "frozen": "0.0",
        "pending": "0.0"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let balance = try! JSONDecoder().decode(AssetBalance.self, from: jsonData)
    let assetSummary: AssetSummary = AssetSummary(asset: asset, balance: balance)

    DerivedAssetRow(asset: assetSummary)
    #else
    let asset: Asset = Asset(id: "1", symbol: "BTC", name: "Bitcoin", type: "", blockchain: "BTC")
    let jsonString = """
    {
        "id": "xxxxx",
        "total": "0.0001",
        "available": "0.0001",
        "frozen": "0.0",
        "pending": "0.0"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let balance = try! JSONDecoder().decode(AssetBalance.self, from: jsonData)
    let assetSummary: AssetSummary = AssetSummary(asset: asset, balance: balance)
    DerivedAssetRow(asset: assetSummary)
    #endif
}
