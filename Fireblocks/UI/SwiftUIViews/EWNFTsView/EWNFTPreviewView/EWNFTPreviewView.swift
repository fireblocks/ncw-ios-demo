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
    @EnvironmentObject var loadingManager: LoadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel
    
    init(dataModel: NFTDataModel) {
        _viewModel = State(initialValue: ViewModel(dataModel: dataModel))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let token = viewModel.dataModel.token {
                List {
                    Section {
                        VStack(spacing: 0) {
                            Text("You're sending")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            EWNFTCard(token: token, isRow: true)
                                .padding()
                                .background(AssetsColors.gray2.color(), in: .rect(cornerRadius: 8))

                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    Section {
                        VStack(spacing: 16) {
                            receivingAddress
                            fireblocksId
                            Divider()
                                .foregroundStyle(.secondary)
                            fee
                            total
                            Divider()
                                .foregroundStyle(.secondary)
                            status
                        }
                        .padding()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
            }
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
            .background()
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
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .contentMargins(.top, 16)

    }
    
    @ViewBuilder
    private var receivingAddress: some View {
        VStack(spacing: 8) {
            Text("Receiving Address")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.b2)
            Text(viewModel.dataModel.address)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .font(.b2)
        }
    }
    
    @ViewBuilder
    private var fee: some View {
        HStack {
            Text("Fee")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.b2)
            Spacer()
            Text("0")
            Text(viewModel.dataModel.token?.blockchainDescriptor?.rawValue ?? "")
                .font(.b2)
        }
    }

    @ViewBuilder
    private var total: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Total")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
                Spacer()
                Text("1")
                Text(viewModel.dataModel.token?.blockchainDescriptor?.rawValue ?? "")
                    .font(.b2)
            }
            HStack {
                Spacer()
                Text("$1")
                    .font(.b2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var status: some View {
        HStack {
            Text("Status")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.b2)
            Spacer()
            Text(viewModel.dataModel.transaction?.status?.rawValue ?? "")
                .font(.b2)
        }
    }

    @ViewBuilder
    private var fireblocksId: some View {
        if let value = viewModel.dataModel.transaction?.id {
            VStack(spacing: 8) {
                Text("Fireblocks Id")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
                HStack {
                    Text(value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.b2)
                    Spacer()
                    Button {
                        viewModel.loadingManager.toastMessage = "Copied to clipboard!"
                        UIPasteboard.general.string = value
                    } label: {
                        Image(uiImage: AssetsIcons.copy.getIcon())
                    }
                    .tint(.white)
                }
            }
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


