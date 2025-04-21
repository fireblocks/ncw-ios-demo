//
//  EWNFTsView.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct EWNFTsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @Environment(EWManager.self) var ewManager

    @State var viewModel = ViewModel()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            if viewModel.dataModel.tokens.isEmpty {
                ContentUnavailableView("NFTs", systemImage: "magnifyingglass", description: Text("No NFTs found on your wallet"))
                    .listRowBackground(Color.clear)
            }
            
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    Text("View as")
                        .foregroundStyle(.secondary)
                    Picker("", selection: $viewModel.selectedViewOption) {
                        ForEach(ViewAsOptions.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    Spacer()
                    Text("Sorted by")
                        .foregroundStyle(.secondary)
                    Picker("", selection: $viewModel.selectedSortingOption) {
                        ForEach(SortingDateOptions.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.top, 16)

                if viewModel.selectedViewOption == .List {
                    list
                } else {
                    gallery
                }
            }
        }
        .navigationTitle("NFTs")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.dataModel.tokens)
        .animation(.default, value: viewModel.selectedSortingOption)
        .animation(.default, value: viewModel.selectedViewOption)
        .animation(.default, value: viewModel.ewManager?.errorMessage)
        .tint(.white)
    }
    
    @ViewBuilder
    private var list: some View {
        List {
            if viewModel.sortedTokens().count > 0 {
                ForEach(self.viewModel.sortedTokens(), id: \.id) { token in
                    Section {
                        EWNFTCard(token: token, isRow: true)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.dataModel.token = token
                                viewModel.proceedToDetails()
                            }
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .refreshable {
            self.loadingManager.isLoading = true
            await viewModel.fetchAllTokens()
        }
        .listStyle(.insetGrouped)
        .contentMargins(.top, 0)

    }
    
    @ViewBuilder
    private var gallery: some View {
        List {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.sortedTokens(), id: \.self) { token in
                    EWNFTCard(token: token, isRow: false)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.dataModel.token = token
                            viewModel.proceedToDetails()
                        }
                }
            }
            .listRowBackground(Color.clear)

        }
        .listStyle(.plain)
        .contentMargins(.top, 0)
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.clear)
        .background(Color.clear)
        .refreshable {
            loadingManager.isLoading = true
            await viewModel.fetchAllTokens()
        }

    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWNFTsView()
        }
    }
}
