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

@Observable
class AssetRowViewModel {
    var asset: AssetSummary
    var uiimage: UIImage?
    var image: Image?
    
    init(asset: AssetSummary) {
        self.asset = asset
        self.uiimage = asset.image
        loadAsset()
    }
    
    private func loadAsset() {
        self.image = Image(uiImage: asset.image)
        Task {
            if let imageURL = asset.iconUrl, let url = URL(string: imageURL) {
                if let uiimage = try? await SessionManager.shared.loadImage(url: url) {
                    await MainActor.run {
                        self.uiimage = uiimage
                        self.image = Image(uiImage: uiimage)
                        if self.image == nil {
                            self.image = Image(uiImage: asset.image)
                        }
                        
                    }
                }
            }
        }

    }
}

struct AssetRow: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    
    let asset: AssetSummary
    @State var viewModel: AssetRowViewModel
    
    init(asset: AssetSummary) {
        self.asset = asset
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
        .animation(.default, value: asset.isExpanded)

    }
    
    @ViewBuilder
    func configAssetView() -> some View {
        HStack(spacing: 16) {
            if let image = viewModel.image {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AssetsColors.gray2.color())
                    .frame(width: 46, height: 46)
                    .overlay {
                        image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    }
            }
            
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(asset.asset?.name ?? "")
                    Spacer()
                    Text(asset.balance?.total?.toDouble?.formatFractions().formatted() ?? "")
                }
                .font(.b1)
                HStack(spacing: 4) {
                    Group {
                        Text(asset.asset?.symbol ?? "")
                        Text(asset.asset?.blockchain ?? "")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(AssetsColors.gray2.color(), in: .capsule)
                    }
                    .font(.b4)
                    Spacer()

                    if let assetId = asset.asset?.id, let total = asset.balance?.total, let price = Double(total) {
                        #if EW
                        Text(CryptoCurrencyManager.shared.getTotalPrice(assetId: assetId, amount: price))
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
                    UIPasteboard.general.string = value
                }
            } label: {
                Label("Copy Address", systemImage: "doc.on.doc")
            }
            .tint(.orange)
        }
    }
}

//#Preview {
//    NavigationContainerView(mockManager: EWManagerMock()) {
//        SpinnerViewContainer {
//            AssetRow(asset: <#T##AssetSummary#>)
//        }
//    }
//}
