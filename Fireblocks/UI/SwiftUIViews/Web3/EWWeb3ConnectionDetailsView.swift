//
//  EWWeb3ConnectionDetailsView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 24/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

struct EWWeb3ConnectionDetailsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel
    
    init(connection: Web3Connection, canRemove: Bool) {
        _viewModel = State(initialValue: ViewModel(connection: connection, canRemove: canRemove))
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack {
                EWWeb3ConnectionDetailsHeader(metadata: viewModel.connection.sessionMetadata, isConnected: true)
                Spacer()
                BottomBanner(text: viewModel.ewManager?.errorMessage)
                    .animation(.default, value: viewModel.ewManager?.errorMessage)
                if viewModel.canRemove {
                    Button {
                        viewModel.removeConnection()
                    } label: {
                        Text("Remove Connection")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AssetsColors.gray2.color())
                    .background(AssetsColors.gray2.color(), in: .capsule)
                    .clipShape(.capsule)
                    .contentShape(.rect)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.connection.sessionMetadata?.appName ?? "Connection Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            if viewModel.canRemove {
                ToolbarItem(placement: .topBarLeading) {
                    CustomBackButtonView()
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        coordinator.path = NavigationPath()
                    } label: {
                        Image(.close)
                    }

                }
            }
        }
        .onAppear() {
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.ewManager?.errorMessage)
    }
}

#Preview("remove true") {
    NavigationContainerView(isPreview: true) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsView(connection: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!, canRemove: true)
        }
    }
}

#Preview("remove false") {
    NavigationContainerView(isPreview: true) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsView(connection: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!, canRemove: false)
        }
    }
}


