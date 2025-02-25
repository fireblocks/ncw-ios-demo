//
//  EWNFTsView.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

struct EWNFTsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @State var viewModel = ViewModel()

    var body: some View {
        VStack {
            List {
                Section {
                    
                    if viewModel.tokens.count > 0 {
                        ForEach(self.viewModel.tokens, id: \.id) { token in
                            HStack {
                                if let imageURL = token.media?.first?.url, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                        case .failure:
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundStyle(.secondary)
                                        @unknown default:
                                            EmptyView()
                                            
                                        }
                                    }
                                    .frame(width: 88, height: 88)
                                    .clipShape(.rect(cornerRadius: 16))
                                    .padding(.bottom, 8)

                                } else {
                                    Image(systemName: "globe")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.secondary)
                                    .frame(width: 88, height: 88)
                                    .clipShape(.rect(cornerRadius: 16))
                                    .padding(.bottom, 8)

                                }
                                if let id = token.id {
                                    Text(id)
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let id = token.id {
                                    coordinator.path.append(NavigationTypes.NFTToken(id))
                                }
                            }
                        }
                    } else {
                        ContentUnavailableView("NFTs", systemImage: "bitcoinsign.circle", description: Text("Tap + button to add new NFT"))
                            .listRowBackground(Color.clear)
                        
                    }
                } header: {
                    HStack {
                        Text("NFTs")
                        Spacer()
//                        Button {
//                            viewModel.isAddConnectionPresented = true
//                        } label: {
//                            Image(systemName: "plus")
//                                .imageScale(.large)
//                        }
                    }
                }
                
            }
            .refreshable {
                await viewModel.fetchAllTokens()
            }
            
            Spacer()
            BottomBanner(text: viewModel.ewManager.errorMessage)
                .animation(.default, value: viewModel.ewManager.errorMessage)
            
        }
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager)
        }
        .animation(.default, value: viewModel.ewManager.errorMessage)
    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            EWNFTsView()
        }
    }
}
