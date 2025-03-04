//
//  EWNFTDetailsView.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 18/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

struct EWNFTDetailsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
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
                        Spacer()
                        HStack {
                            name
                            Spacer()
                            tokenId
                        }
                        .padding()
                        Divider()
                        Group {
                            dateAcquired
                            collection
                            blockchain
                            standard
                            balance
                            contactAddress
                            nftId
                        }
                        .padding()
                    }
//                    .background(AssetsColors.gray2.color(), in: .rect)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.clear)
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
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
            .background()
        })
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager, coordinator: coordinator)
        }
        .navigationTitle("NFT Details")
        .navigationBarTitleDisplayMode(.inline)
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
            Text(tokenId)
        }
    }

    @ViewBuilder
    private var standard: some View {
        if let value = viewModel.dataModel.token?.standard {
            TitleValueRow(title: "Standard", value: value)
        }
    }

    @ViewBuilder
    private var balance: some View {
        if let value = viewModel.dataModel.token?.balance {
            TitleValueRow(title: "Balance", value: value)
        }
    }

    @ViewBuilder
    private var dateAcquired: some View {
        if let ownershipStartTime = viewModel.dataModel.token?.ownershipStartTime {
            TitleValueRow(title: "Date Acquired", value: Date(timeIntervalSince1970: TimeInterval(ownershipStartTime)).format())
        }
    }

    @ViewBuilder
    private var collection: some View {
        if let collection = viewModel.dataModel.token?.collection?.name {
            TitleValueRow(title: "Collection", value: collection)
        }
    }

    @ViewBuilder
    private var blockchain: some View {
        if let blockchain = viewModel.dataModel.token?.blockchainDescriptor?.rawValue {
            TitleValueRow(title: "Blockchain", value: blockchain)
        }
    }

    @ViewBuilder
    private var contactAddress: some View {
        if let value = viewModel.dataModel.token?.collection?.id {
            VStack(spacing: 8) {
                Text("Contact address")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
                HStack {
                    Text(value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.b2)
                    Spacer()
                    Image(uiImage: AssetsIcons.copy.getIcon())

                }
                .contentShape(.rect)
                .onTapGesture {
                    loadingManager.toastMessage = "Copied!"
                    UIPasteboard.general.string = value

                }
            }
        }
    }

    @ViewBuilder
    private var nftId: some View {
        if let value = viewModel.dataModel.token?.id {
            VStack(spacing: 8) {
                Text("Id")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
                HStack {
                    Text(value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.b2)
                    Spacer()
                    Image(uiImage: AssetsIcons.copy.getIcon())
                }
                .contentShape(.rect)
                .onTapGesture {
                    loadingManager.toastMessage = "Copied!"
                    UIPasteboard.general.string = value
                }
            }
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


