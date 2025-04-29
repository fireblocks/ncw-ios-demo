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
    @Environment(LoadingManager.self) var loadingManager
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
            VStack(spacing: 0) {
                if viewModel.transaction.txId != nil {
                    List {
                        if viewModel.isTransferring {
                            Section {
                                VStack(alignment: .center, spacing: 0) {
                                    Image(.transferring)
                                        .resizable()
                                        .frame(width: 75, height: 75)
                                        .padding(.bottom)
                                    Text(LocalizableStrings.transferring)
                                        .font(.h3)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(LocalizableStrings.transferringDuration)
                                        .font(.b2)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                }
                                .clipped()
                                .compositingGroup()
                                
                            }
                            .listRowBackground(Color.clear)
                        }
                        VStack(spacing: 0) {
                            TransactionHeaderView(transaction: viewModel.transaction, transferInfo: viewModel.transferInfo)
                            Divider()
                            
                            let views: [AnyView] = [
                                AnyView(recipient),
                                AnyView(fee),
                                AnyView(status),
                                AnyView(creationDate),
                                AnyView(fireblocksId),
                                AnyView(transactionHash),
                                AnyView(fireblocksNftId)
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
        .navigationTitle(LocalizableStrings.transactionDetails)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .contentMargins(.top, 16)
        .animation(.default, value: viewModel.isTransferring)
    }

    @ViewBuilder
    private var fireblocksNftId: some View {
        let transferInfo: TransferInfo? = viewModel.transferInfo
        if (transferInfo?.isNFT() == true) {
            let nftView = DetailsListItemView(
                title: LocalizableStrings.fireblocksNFTId,
                contentText: transferInfo?.assetId,
                showCopyButton: true
            )
            nftView
        }
    }
    
    @ViewBuilder
    private var creationDate: some View {
        DetailsListItemView(
            title: LocalizableStrings.creationDate,
            contentText: viewModel.getCreationDate(),
            showCopyButton: false
        )
    }
    
    @ViewBuilder
    private var recipient: some View {
        DetailsListItemView(
            title: LocalizableStrings.recipient,
            contentText: viewModel.getReceivedFrom(),
            showCopyButton: true
        )
    }

    
    @ViewBuilder
    private var fee: some View {
        DetailsListItemView(
            title: LocalizableStrings.fee,
            contentText: viewModel.getFee()
        )
    }
    
    @ViewBuilder
    private var status: some View {
        if let transferInfo = viewModel.transferInfo {
            DetailsListItemView(
                title: LocalizableStrings.status,
                contentText: transferInfo.status.rawValue.beautifySigningStatus(),
                contentColor: transferInfo.getColor()
            )
        }
    }

    @ViewBuilder
    private var transactionHash: some View {
        let transactionHash = viewModel.getTransactionHash()
        if !transactionHash.isEmpty {
            DetailsListItemView(
                title: LocalizableStrings.transactionHash,
                contentText: transactionHash,
                showCopyButton: true
            )
        }
    }

    
    @ViewBuilder
    private var fireblocksId: some View {
        DetailsListItemView(
            title: LocalizableStrings.fireblocksTransactionId,
            contentText: viewModel.getTransactionId(),
            showCopyButton: true
        )
    }
        

    @ViewBuilder
    private var buttons: some View {
        if let transactionInfo = viewModel.transferInfo {
            ZStack {
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
                .opacity(transactionInfo.status == .pendingSignature && !viewModel.isTransferring ? 1 : 0)
                .disabled(transactionInfo.status != .pendingSignature)
                .animation(.default, value: viewModel.transferInfo?.status)
                .background(transactionInfo.status == .pendingSignature ? nil : Color.clear)

                HStack {
                    Button {
                        viewModel.coordinator?.path = NavigationPath()
                    } label: {
                        Text("Go to wallet")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AssetsColors.gray2.color())
                    .background(AssetsColors.gray2.color(), in: .capsule)
                    .clipShape(.capsule)
                    .contentShape(.rect)
                    .opacity(viewModel.isTransferring ? 1 : 0)
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private func discardAlert() -> some View {
        DiscardAlert(title: "Cancel transaction?", mainTitle: "Cancel transaction", image: .errorBox) {
            viewModel.isDiscardAlertPresented = false
            viewModel.cancelTransaction()
        }
    }

}



#Preview {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            ApproveTransactionView(transaction: TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).toTransaction(assetListViewModel: AssetListViewModelMock())!, fromCreate: true)
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


