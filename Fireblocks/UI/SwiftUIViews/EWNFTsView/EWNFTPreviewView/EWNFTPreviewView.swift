//
//  EWNFTPreviewView.swift
//  EW-dev
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct EWNFTPreviewView: View {
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
                if let token = viewModel.dataModel.token {
                    List {
                        Section {
                            EWNFTCard(token: token, isRow: true)
                                .padding()
                                .background(AssetsColors.gray2.color(), in: .rect(cornerRadius: 8))
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        VStack(spacing: 0) {
                            let views: [AnyView] = [
                                AnyView(recipient),
                                AnyView(status),
                                AnyView(fireblocksId),
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
            }
            .background(Color.clear)
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
                Button {
                    viewModel.approveTransaction()
                } label: {
                    Label("Approve", systemImage: "checkmark")
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
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.cancelTransaction()
                } label: {
                    Image(.close)
                        .tint(.white)
                }
            }
        })
        .animation(.default, value: viewModel.dataModel.feeLevel)
        .animation(.default, value: viewModel.dataModel.transaction?.status)
        .navigationTitle(LocalizableStrings.transferNFT)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .contentMargins(.top, 16)
    }
    
    @ViewBuilder
    private var recipient: some View {
        DetailsListItemView(
            title: LocalizableStrings.recipient,
            contentText: viewModel.dataModel.address,
            showCopyButton: true
        )
    }
    
    @ViewBuilder
    private var status: some View {
        if let transaction = viewModel.dataModel.transaction {
            if let status = transaction.status {
                DetailsListItemView(
                    title: LocalizableStrings.status,
                    contentText: status.rawValue.beautifySigningStatus(),
                    contentColor: Color(TransferUtils.getStatusColor(status: status))
                )
            }
        }
    }
    
    @ViewBuilder
    private var fireblocksId: some View {
        if let value = viewModel.dataModel.transaction?.id {
            DetailsListItemView(
                title: LocalizableStrings.fireblocksTransactionId,
                contentText: value,
                showCopyButton: true
            )
        }
    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWNFTPreviewView(dataModel: NFTDataModel.mock())
        }
    }
}


