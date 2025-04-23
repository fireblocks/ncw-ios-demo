//
//  ReceiveAssetHeaderView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 22/04/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct ReceiveAssetHeaderView: View {
    let asset: AssetSummary
    let blockchain: String
    @State var viewModel: AssetRowViewModel
    
    init(asset: AssetSummary) {
        self.asset = asset
        self.blockchain = asset.asset?.blockchain ?? ""
        _viewModel = .init(initialValue: .init(asset: asset))
    }

    var body: some View {
        VStack(spacing: 0) {
            CryptoIconCardView(asset: asset, showBlockchainImage: true)
                .padding(.bottom, 8)
            Text(asset.asset?.name ?? "")
                .font(.h3)
            Text(BlockchainProvider.shared.getBlockchain(blockchainName: blockchain)?.displayName ?? blockchain)
                .font(.b1)
                .foregroundStyle(.secondary)
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

    ReceiveAssetHeaderView(asset: assetSummary)
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
    ReceiveAssetHeaderView(asset: assetSummary)
    #endif
}
