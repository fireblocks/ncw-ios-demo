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
    @EnvironmentObject var fireblocksManager: FireblocksManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    @State var viewModel: ApproveViewModel
    
    init(transaction: FBTransaction, fromCreate: Bool = false) {
        _viewModel = State(initialValue: ApproveViewModel(transaction: transaction, fromCreate: fromCreate))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let txId = viewModel.transaction.txId {
                List {
                    Section {
                        VStack(spacing: 0) {
                            if let isEndedTransaction = viewModel.transferInfo?.isEndedTransaction(), !isEndedTransaction {
                                Text("You're sending")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
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
        .safeAreaInset(edge: .bottom, content: {
//            if viewModel.transferInfo?.status == .pendingSignature {
                buttons
//                    .background()
//            }
        })
        .onAppear() {
            #if EW
            viewModel.setup(coordinator: coordinator, loadingManager: loadingManager, ewManager: ewManager, fireblocksManager: fireblocksManager)
            #else
            viewModel.setup(coordinator: coordinator, loadingManager: loadingManager, fireblocksManager: fireblocksManager)
            #endif
        }
        .toolbar(content: {
            if viewModel.fromCreate {
                if let transactionInfo = viewModel.transferInfo, !transactionInfo.isEndedTransaction() {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.isDiscardAlertPresented = true
                        } label: {
                            Image(.close)
                                .tint(.white)
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        coordinator.path = NavigationPath()
                    } label: {
                        Image(.backButton)
                    }
                }

            } else {
                ToolbarItem(placement: .topBarLeading) {
                    CustomBackButtonView()
                }

            }
        })
        .sheet(isPresented: $viewModel.isDiscardAlertPresented, content: {
            discardAlert()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)

        })
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

    @ViewBuilder
    private var buttons: some View {
        if let transactionInfo = viewModel.transferInfo {
            HStack(spacing: 16) {
                Button {
                    viewModel.isDiscardAlertPresented = true
                } label: {
                    Text("Deny")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
                .background(AssetsColors.gray2.color(), in: .capsule)
                .clipShape(.capsule)
                .contentShape(.rect)
                
                Button {
                    viewModel.approveTransaction()
                } label: {
                    Text("Approve")
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
            .opacity(transactionInfo.status == .pendingSignature ? 1 : 0)
            .disabled(transactionInfo.status != .pendingSignature)
            .animation(.default, value: viewModel.transferInfo?.status)
            .background(transactionInfo.status == .pendingSignature ? nil : Color.clear)
        }
    }
    
    @ViewBuilder
    private func discardAlert() -> some View {
        DiscardAlert(title: "Are you sure you want to discard this transaction", mainTitle: "Discard transaction") {
            viewModel.isDiscardAlertPresented = false
            viewModel.cancelTransaction()

        }
    }

}

#Preview {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            ApproveTransactionView(transaction: TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).toTransaction(assetListViewModel: AssetListViewModelMock())!, fromCreate: false)
        }
    }
    #else
//    NavigationContainerView() {
//        SpinnerViewContainer {
//            ApproveTransactionView(transaction: TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).toTransaction(assetListViewModel: AssetListViewModelMock())!)
//        }
//    }
    #endif
}


