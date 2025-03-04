//
//  ApproveTransactionView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 03/03/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct ApproveTransactionView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    @State var viewModel: ApproveViewModel
    
    init(transaction: FBTransaction, fromCreate: Bool = false) {
        _viewModel = State(initialValue: ApproveViewModel(transaction: transaction))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let txId = viewModel.transaction.txId {
                List {
                    Section {
                        VStack(spacing: 0) {
                            Text("You're sending")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            TransactionHeaderView(transaction: viewModel.transaction, transferInfo: viewModel.transferInfo)

                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    Section {
                        VStack(spacing: 16) {
                            creationDate
                            receivedFrom
                            fee
                            transactionHash
                            fireblocksId
                            assetId
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
            }
        }
//        .safeAreaInset(edge: .bottom, content: {
//            VStack(spacing: 8) {
//                Button {
//                    viewModel.approveTransaction()
//                } label: {
//                    Label("Approve", systemImage: "checkmark")
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(8)
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(AssetsColors.gray2.color())
//                .background(AssetsColors.gray2.color(), in: .capsule)
//                .clipShape(.capsule)
//                .contentShape(.rect)
//
//            }
//            .padding()
//            .background()
//        })
        .onAppear() {
            #if EW
            viewModel.setup(coordinator: coordinator, loadingManager: loadingManager, ewManager: ewManager)
            #else
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator)
            #endif
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
//        .animation(.default, value: viewModel.dataModel.feeLevel)
//        .animation(.default, value: viewModel.dataModel.transaction?.status)
        .scrollContentBackground(.hidden)
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .contentMargins(.top, 16)

    }
    
    @ViewBuilder
    private var creationDate: some View {
        VStack(spacing: 8) {
            Text("Creation date")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.b2)
            Text(viewModel.getCreationDate())
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .font(.b2)
        }
    }
    
    @ViewBuilder
    private var receivedFrom: some View {
        VStack(spacing: 8) {
            Text(viewModel.getReceivedFromTitle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.b2)
            HStack {
                Text(viewModel.getReceivedFrom())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.b2)
                Spacer()
                Image(uiImage: AssetsIcons.copy.getIcon())

            }
            .contentShape(.rect)
            .onTapGesture {
                loadingManager.toastMessage = "Copied!"
                UIPasteboard.general.string = viewModel.getReceivedFrom()

            }

        }
    }

    
    @ViewBuilder
    private var fee: some View {
        VStack(spacing: 8) {
            Text("Fee")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.secondary)
                .font(.b2)
            Text(viewModel.getFee())
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.b2)
        }
    }

    @ViewBuilder
    private var transactionHash: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Transaction hash")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
            }
            HStack {
                Text(viewModel.getTransactionHash())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.b2)
                Spacer()
                Image(uiImage: AssetsIcons.copy.getIcon())
            }
            .contentShape(.rect)
            .onTapGesture {
                loadingManager.toastMessage = "Copied!"
                UIPasteboard.general.string = viewModel.getTransactionHash()

            }
        }
    }
    
    @ViewBuilder
    private var fireblocksId: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Fireblocks Id")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
            }
            HStack {
                Text(viewModel.getTransactionId())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.b2)
                Spacer()
                Image(uiImage: AssetsIcons.copy.getIcon())
            }
            .contentShape(.rect)
            .onTapGesture {
                loadingManager.toastMessage = "Copied!"
                UIPasteboard.general.string = viewModel.getTransactionId()

            }
        }
    }
    
    @ViewBuilder
    private var assetId: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Asset Id")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.b2)
            }
            HStack {
                Text(viewModel.getAssetId())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .font(.b2)
                Spacer()
                Image(uiImage: AssetsIcons.copy.getIcon())
            }
            .contentShape(.rect)
            .onTapGesture {
                loadingManager.toastMessage = "Copied!"
                UIPasteboard.general.string = viewModel.getAssetId()

            }
        }
    }

}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            ApproveTransactionView(transaction: TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).toTransaction(assetListViewModel: AssetListViewModelMock())!)
//
//            VStack {
//                Text(TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).assetId ?? "XXX")
//                Text(AssetListViewModelMock().getAssetSummary().first?.asset?.id ?? "XXX")
//                Text(TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).toTransaction(assetListViewModel: AssetListViewModelMock())?.txId ?? "XXX")
//            }
        }
    }
}


