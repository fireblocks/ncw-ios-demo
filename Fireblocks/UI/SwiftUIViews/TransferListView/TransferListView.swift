//
//  TransferListView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/03/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct TransferListView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    
    @StateObject var viewModel = TransfersViewModel.shared
    @State var selectedTransfer: TransferInfo?
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            if viewModel.transfers.isEmpty {
                ContentUnavailableView("Transfer", systemImage: "magnifyingglass", description: Text("No transfers found on your wallet"))
                    .listRowBackground(Color.clear)
            }
            list
        }
        .navigationTitle("Transfer history")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: viewModel.selectedTransfer)
        .tint(.white)
        .onAppear {
        #if EW
            viewModel.setup(ewManager: ewManager)
        #endif
        }
    }
    
    @ViewBuilder
    private var list: some View {
        List {
            if viewModel.transfers.count > 0 {
                ForEach(self.viewModel.sortedTransfers) { transfer in
                    TransferRow(transferInfo: transfer)
                        .contentShape(.rect)
                        .onTapGesture {
                            if let transaction = transfer.toTransaction(assetListViewModel: AssetListViewModel.shared) {
                                coordinator.path.append(NavigationTypes.approveTransaction(transaction, false))
                            }
                        }
                        .listRowBackground(Color.clear)

                }
            }
        }
        .listStyle(.plain)
        .contentMargins(.top, 16)
    }

}

//#Preview {
//    NavigationContainerView(mockManager: EWManagerMock()) {
//        SpinnerViewContainer {
//            AssetListView()
//        }
//    }
//}
