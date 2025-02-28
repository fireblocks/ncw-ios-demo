//
//  AssetListView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 28/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

struct AssetListView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    
    @State var viewModel = AssetListViewModel.shared

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            if viewModel.assetsSummary.isEmpty {
                ContentUnavailableView("Assets", systemImage: "magnifyingglass", description: Text("No assets found on your wallet"))
                    .listRowBackground(Color.clear)
            }
            
            VStack(spacing: 0) {
                list
                Spacer()
                BottomBanner(text: viewModel.ewManager?.errorMessage)
                    .animation(.default, value: viewModel.ewManager?.errorMessage)
                
            }
        }
        .navigationTitle("Assets")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            #if EW
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager, coordinator: coordinator)
            #endif
        }
        .animation(.default, value: viewModel.assetsSummary)
        .animation(.default, value: viewModel.ewManager?.errorMessage)
        .tint(.white)
    }
    
    @ViewBuilder
    private var list: some View {
        List {
            assetSummaryBanner
            addAssets
            assetList
        }
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .refreshable {
            self.loadingManager.isLoading = true
            viewModel.fetchAssets()
        }
        .listStyle(.insetGrouped)
        .contentMargins(.top, 16)
        .sheet(isPresented: $viewModel.addAssetPresented) {
            NavigationContainerView {
                GenericController(uiViewType: AddAssetsViewController(devideId: FireblocksManager.shared.getDeviceId(), delegate: viewModel))
                    .navigationTitle("Select Asset")
                    .navigationBarTitleDisplayMode(.inline)
                    .tint(.white)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                viewModel.addAssetPresented = false
                            } label: {
                                Image(.close)
                                    .tint(.white)
                            }
                        }
                    }
            }
        }
    }

    @ViewBuilder
    var assetSummaryBanner: some View {
        Section {
            VStack(spacing: 24) {
                Text("Balance")
                    .font(.b2)
                Text(viewModel.getBalance())
                    .font(.h1)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
    }
    
    @ViewBuilder
    var addAssets: some View {
        Section {
            HStack {
                Text("Assets")
                    .font(.b2)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    viewModel.addAssetPresented = true
                } label: {
                    Image(.plus)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
            }
            .background(Color.clear)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }

    }
    
    @ViewBuilder
    var assetList: some View {
        if viewModel.assetsSummary.count > 0 {
            ForEach(self.viewModel.assetsSummary, id: \.id) { assetSummary in
                Section {
                    AssetRow(asset: assetSummary)
                        .listRowBackground(AssetsColors.gray1.color())
                        .listRowSeparator(.hidden)
                        .contentShape(.rect)
                        .onTapGesture {
                            viewModel.toggleAssetExpanded(asset: assetSummary)
                        }
                }
            }
        }

    }

    
}

//#Preview {
//    NavigationContainerView(mockManager: EWManagerMock()) {
//        SpinnerViewContainer {
//            AssetListView()
//        }
//    }
//}
