//
//  AssetRow.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 28/02/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct AssetRow: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    
    let asset: AssetSummary
    var titleAmount: String?
    var subTitleAmount: String?
    
    @State var viewModel: AssetRowViewModel
    
    init(asset: AssetSummary, titleAmount: String? = nil, subTitleAmount: String? = nil) {
        self.asset = asset
        self.titleAmount = titleAmount
        self.subTitleAmount = subTitleAmount
        _viewModel = .init(initialValue: .init(asset: asset))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            configAssetView()
            assetButtons()
                .padding(.top, 16)
                .frame(height: asset.isExpanded ? nil : 0)
                .opacity( asset.isExpanded ? 1 : 0)
        }
        .compositingGroup()
        .animation(.default, value: asset.isExpanded)
        .onAppear() {
            #if EW
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager)
            #endif
        }
    }
    
    @ViewBuilder
    func configAssetView() -> some View {
        HStack(spacing: 16) {
            CryptoIconCardView(asset: asset, showBlockchainImage: true)
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    let title = AssetsUtils.getAssetTitleText(asset: asset.asset)
                    Text(title)
                    Spacer()
                    Text(titleAmount ?? asset.balance?.total?.toDouble?.formatFractions().formatted() ?? "")
                }
                .font(.b1)
                HStack(spacing: 4) {
                    Text(asset.asset?.name ?? "")
                    .font(.b4)
                    Spacer()

                    if let subTitleAmount {
                        Text(subTitleAmount)
                            .font(.b2)
                    } else {
                        if let assetId = asset.asset?.id, let total = asset.balance?.total, let price = Double(total) {
#if EW
                            Text(CryptoCurrencyManager.shared.getTotalPrice(assetId: assetId, networkProtocol: asset.asset?.networkProtocol, amount: price))
                                .font(.b2)
#else
                            if let rate = asset.asset?.rate, let total = asset.balance?.total, let price = Double(total), price != 0 {
                                let rounded = String(format: "%.\(2)f", (price * rate))
                                Text("$\(rounded)")
                                    .font(.b2)
                            }
#endif
                        }
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    func assetButtons() -> some View {
        HStack(spacing: 16) {
            Button {
                coordinator.path.append(NavigationTypes.genericController(AmountToSendViewController(asset: asset), "Send"))
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(.send)
                    Text("Send")
                    Spacer()
                }
                .font(.b2)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .contentShape(.rect)
            .tint(AssetsColors.gray2.color())
            
            Button {
                coordinator.path.append(NavigationTypes.genericController(ReceiveViewController(asset: asset), "Receive"))
            } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(.receive)
                    Text("Receive")
                    Spacer()
                }
                .font(.b2)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 48)
            }
            .buttonStyle(.borderedProminent)
            .contentShape(.rect)
            .tint(AssetsColors.gray2.color())
        }
        .swipeActions {
            Button {
                if let value = asset.address?.address {
                    loadingManager.toastMessage = "Address copied to clipboard"
                    UIPasteboard.general.string = value
                }
            } label: {
                Label("Address", systemImage: "doc.on.doc")
            }
            .tint(.orange)
            
            #if EW
            #if DEV
            Button {
                viewModel.refreshBalance()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .tint(.blue)
            #endif
            #endif

        }

    }
}

#Preview {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
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
        
            AssetRow(asset: assetSummary)
        }
    }
    #else
    NavigationContainerView() {
        SpinnerViewContainer {
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
        
            AssetRow(asset: assetSummary)
        }
    }
    #endif
}

