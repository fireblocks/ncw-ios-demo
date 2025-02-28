//
//  EWWeb3ConnectionSubmitView.swift
//  EW-dev
//
//  Created by Dudi Shani-Gabay on 24/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

struct EWWeb3ConnectionSubmitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel
    
    init(dataModel: Web3DataModel) {
        _viewModel = State(initialValue: ViewModel(dataModel: dataModel))
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            if let response = viewModel.dataModel.response {
                VStack {
                    EWWeb3ConnectionDetailsHeader(metadata: response.sessionMetadata, isConnected: false)
                    
                    Spacer()
                    BottomBanner(text: viewModel.ewManager?.errorMessage)
                        .animation(.default, value: viewModel.ewManager?.errorMessage)
                    
                    Button {
                        viewModel.submitConnection(approve: true)
                    } label: {
                        Text("Connect")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AssetsColors.gray2.color())
                    .background(AssetsColors.gray2.color(), in: .capsule)
                    .clipShape(.capsule)
                    .contentShape(.rect)
                    
                    Button {
                        viewModel.submitConnection(approve: false)
                    } label: {
                        Text("Discard")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                    }
                    .tint(.secondary)
                    .background(.clear, in: .capsule)
                    .clipShape(.capsule)
                    .contentShape(.rect)
                }
                .padding()
            }
            
            VStack {
                Group {
                    if let image = viewModel.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 72, height: 72)
                            .clipShape(.rect(cornerRadius: 8))
                    } else {
                        Text("DAPP")
                            .placeholderHeader()
                    }
                }
                Spacer()

            }
            .padding()

        }
        .navigationTitle("Review connection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.discard()
                } label: {
                    Image(.close)
                        .tint(.white)
                }

            }
        }
        .onAppear() {
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.ewManager?.errorMessage)
    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWWeb3ConnectionSubmitView(dataModel: Web3DataModel.mock())
        }
    }
}

