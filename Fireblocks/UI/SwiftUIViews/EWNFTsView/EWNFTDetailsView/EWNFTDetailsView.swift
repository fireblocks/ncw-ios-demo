//
//  EWNFTDetailsView.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 18/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct EWNFTDetailsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel
    
    init(dataModel: NFTDataModel) {
        _viewModel = State(initialValue: ViewModel(dataModel: dataModel))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                List {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            if let image = viewModel.image {
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.top, 16)
                            }
                            Spacer()
                        }
                        .frame(height: 185)
                        .background(viewModel.uiimage?.averageColor ?? Color.clear)
                        HStack(spacing: 0) {
                            name
                            Spacer()
                        }
                        .padding()
                        .background(Color(.background))
                        Divider()
                        
                        let views: [AnyView] = [
                            AnyView(amount),
                            AnyView(dateAcquired),
                            AnyView(collection),
                            AnyView(tokenId),
                            AnyView(blockchain),
                            AnyView(standard),
                            AnyView(contactAddress),
                            AnyView(nftId),
                        ]
                        
                        VStack(spacing: 0) {
                            ForEach(0..<views.count, id: \.self) { index in
                                views[index]
                                if index < views.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .scrollContentBackground(.hidden)
            }
            .padding(.bottom, 1)
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 6) {
                Button {
                    viewModel.proceedToTransfer()
                } label: {
                    Text("Transfer NFT")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
                .background(AssetsColors.gray2.color(), in: .capsule)
                .clipShape(.capsule)
                .contentShape(.rect)

            }
            .padding()
        })
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager, coordinator: coordinator)
        }
        .navigationTitle("NFT Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .contentMargins(.top, 16)
    }
    
    @ViewBuilder
    private var name: some View {
        if let name = viewModel.dataModel.token?.name?.capitalized {
            Text(name)
        }
    }

    @ViewBuilder
    private var tokenId: some View {
        if let tokenId = viewModel.dataModel.token?.tokenId {
            let tokenId = "#" + tokenId
            DetailsListItemView(
                title: LocalizableStrings.tokenId,
                contentText: tokenId
            )
        }
    }

    @ViewBuilder
    private var standard: some View {
        if let value = viewModel.dataModel.token?.standard {
            DetailsListItemView(
                title: LocalizableStrings.standard,
                contentText: value,
                showCopyButton: true
            )
        }
    }

    @ViewBuilder
    private var amount: some View {
        if let value = viewModel.dataModel.token?.balance {
            DetailsListItemView(
                title: LocalizableStrings.amount,
                contentText: value
            )
        }
    }

    @ViewBuilder
    private var dateAcquired: some View {
        if let ownershipStartTime = viewModel.dataModel.token?.ownershipStartTime {
            DetailsListItemView(
                title: LocalizableStrings.dateAcquired,
                contentText: Date(timeIntervalSince1970: TimeInterval(ownershipStartTime)).format()
            )
        }
    }

    @ViewBuilder
    private var collection: some View {
        if let collection = viewModel.dataModel.token?.collection?.name {
            DetailsListItemView(
                title: LocalizableStrings.collection,
                contentText: collection
            )
        }
    }

    @ViewBuilder
    private var blockchain: some View {
        if let blockchain = viewModel.dataModel.token?.blockchainDescriptor?.rawValue {
            SymbolListItemView(
                title: LocalizableStrings.blockchain,
                blockchain: AssetsUtils.getBlockchainDisplayName(blockchainName: blockchain),
                blockchainSymbol: blockchain
            )
        }
    }

    @ViewBuilder
    private var contactAddress: some View {
        if let value = viewModel.dataModel.token?.collection?.id {
            DetailsListItemView(
                title: LocalizableStrings.contactAddress,
                contentText: value,
                showCopyButton: true
            )
        }
    }

    @ViewBuilder
    private var nftId: some View {
        if let value = viewModel.dataModel.token?.id {
            DetailsListItemView(
                title: LocalizableStrings.fireblocksNFTId,
                contentText: value,
                showCopyButton: true
            )
        }
    }

}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWNFTDetailsView(dataModel: NFTDataModel.mock())
        }
    }
}


