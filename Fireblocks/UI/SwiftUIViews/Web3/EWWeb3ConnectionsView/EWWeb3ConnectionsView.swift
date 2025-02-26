//
//  EWWeb3ConnectionsView.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 17/02/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

struct EWWeb3ConnectionsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @Environment(EWManager.self) var ewManager
    
    @State var viewModel: ViewModel
    
    init(accountId: Int) {
        _viewModel = State(initialValue: ViewModel(accountId: accountId))
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack {
                List {
                    HStack {
                        Text("Connected dApps")
                            .font(.b2)
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            coordinator.path.append(NavigationTypes.createConnection(viewModel.accountId))
                        } label: {
                            Image(.plus)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AssetsColors.gray2.color())
                    }
                    .background(Color.clear)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                        if viewModel.connections.count > 0 {
                            ForEach(self.viewModel.connections, id: \.id) { connection in
                                Section {
                                    E3WebConnectionRow(connection: connection)
                                    .contentShape(.rect)
                                    .onTapGesture(perform: {
                                        coordinator.path.append(NavigationTypes.connectionDetails(connection, true))
                                    })
                                }
                            }
                        }
                    
                }
                .listSectionSpacing(.compact)
                .refreshable {
                    loadingManager.isLoading = true
                    viewModel.fetchAllConnections()
                }

                Spacer()
                BottomBanner(text: viewModel.ewManager?.errorMessage)
                    .animation(.default, value: viewModel.ewManager?.errorMessage)
                
            }

        }
        .navigationTitle("Web3 Connections")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager)
        }
        .animation(.default, value: viewModel.ewManager?.errorMessage)
        .animation(.default, value: viewModel.connections)
        .tint(.white)
    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWWeb3ConnectionsView(accountId: 0)
        }
    }
}
