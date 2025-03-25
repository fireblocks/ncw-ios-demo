//
//  EWWeb3ConnectionDetailsView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 24/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct EWWeb3ConnectionDetailsView: View {
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
            if let connection = viewModel.dataModel.connection {
                VStack {
                    EWWeb3ConnectionDetailsHeader(connection: connection, metadata: connection.sessionMetadata, isConnected: true)
                        .environment(ewManager)
                        .environmentObject(loadingManager)
                    Spacer()
//                    BottomBanner(message: viewModel.ewManager?.errorMessage)
//                        .animation(.default, value: viewModel.ewManager?.errorMessage)
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
                .padding()
            }
        }
        .navigationTitle(viewModel.dataModel.connection?.sessionMetadata?.appName ?? "Connection Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CustomBackButtonView()
            }
        }
        .onAppear() {
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.ewManager?.errorMessage)
    }
}

#Preview("remove true") {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsView(dataModel: Web3DataModel.mock())
        }
    }
}

//#Preview("remove false") {
//    NavigationContainerView(mockManager: EWManagerMock()) {
//        SpinnerViewContainer {
//            EWWeb3ConnectionDetailsView(dataModel: Web3DataModel.mock())
//        }
//    }
//}


