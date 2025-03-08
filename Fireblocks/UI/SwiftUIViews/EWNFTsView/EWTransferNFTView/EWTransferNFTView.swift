//
//  EWTransferNFTView.swift
//  EW-dev
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct EWTransferNFTView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel
    
    init(dataModel: NFTDataModel) {
        _viewModel = State(initialValue: ViewModel(dataModel: dataModel))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if let token = viewModel.dataModel.token {
                List {
                    Section {
                        VStack(spacing: 0) {
                            EWNFTCard(token: token, isRow: true)
                                .padding()
                        }
                    }
                    .background(AssetsColors.gray2.color(), in: .rect)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    Section {
                        VStack {
                            Text("Scan or enter a receiving address ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.b2)
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AssetsColors.gray2.color())
                                        .frame(height: 42)
                                        .overlay {
                                            Text("Enter address")
                                                .font(.b4)
                                                .foregroundStyle(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .opacity(viewModel.dataModel.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1 : 0)
                                                .padding(.horizontal, 8)
                                            
                                        }
                                    TextField("", text: $viewModel.dataModel.address)
                                        .font(.b2)
                                        .textFieldStyle(.plain)
                                        .padding(.horizontal, 8)
                                }
                                Button {
                                    viewModel.presentQRCodeScanner()
                                } label: {
                                    Image(.scanQrCode)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 20)
                                        .padding(8)
                                    
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AssetsColors.gray2.color())
                                .contentShape(.rect)
                            }
                        }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
//                BottomBanner(message: viewModel.ewManager?.errorMessage)
//                    .animation(.default, value: viewModel.ewManager?.errorMessage)
                Button {
                    viewModel.proceedToFee()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
                .background(AssetsColors.gray2.color(), in: .capsule)
                .clipShape(.capsule)
                .contentShape(.rect)
                .disabled(viewModel.dataModel.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            }
            .padding()
            .background()
        })
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.dataModel.address)
        .navigationTitle("NFT Transfer")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .contentMargins(.top, 16)
        .fullScreenCover(isPresented: $viewModel.isQRPresented, content: {
            NavigationStack {
                GenericController(uiViewType: QRCodeScannerViewController(delegate: viewModel)
                )
                .navigationTitle("Scan Address QR")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.isQRPresented = false
                        } label: {
                            Image(.close)
                                .tint(.white)
                        }
                    }
                }
            }
        })

    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWTransferNFTView(dataModel: NFTDataModel.mock())
        }
    }
}


