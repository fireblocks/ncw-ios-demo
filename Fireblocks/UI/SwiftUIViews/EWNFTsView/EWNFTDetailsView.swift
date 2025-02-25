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
    @State var viewModel: ViewModel
    
    init(id: String) {
        _viewModel = State(initialValue: ViewModel(id: id))
    }

    var body: some View {
        VStack {
            List {
                if viewModel.token != nil {
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
                    }
                    .background(.thinMaterial, in: .rect)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } else {
                    ContentUnavailableView("Loading NFT", systemImage: "bitcoinsign.circle", description: Text(""))
                        .listRowBackground(Color.clear)
                    
                }

            }
            .refreshable {
                await viewModel.getNFT()
            }
            
            Spacer()
            Button("Transfer NFT") {
                print("transfer")
            }
            .buttonStyle(.borderedProminent)

            BottomBanner(text: viewModel.ewManager.errorMessage)
                .animation(.default, value: viewModel.ewManager.errorMessage)
            
        }
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager)
        }
        .animation(.default, value: viewModel.ewManager.errorMessage)
        .navigationTitle("NFT Details")
    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            EWNFTDetailsView(id: "xxx")
        }
    }
}


