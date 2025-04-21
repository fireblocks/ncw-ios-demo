//
//  EWWeb3ConnectionURI.swift
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

struct EWWeb3ConnectionURI: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel

    init(dataModel: Web3DataModel) {
        _viewModel = State(initialValue: ViewModel(dataModel: dataModel))
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            ReceivingAddressGenericView(
                onContinueClicked: { uri in
                    viewModel.dataModel.uri = uri
                    viewModel.createConnection()
                },
                scanTitleResId: "Scan dApp QR code",
                scanSubtitleResId: "Open a dApp that supports WalletConnect, click here and scan the QR code.",
                hint: "Enter address"
            )
        }
        .navigationTitle("Connect dApp")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .onAppear() {
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.ewManager?.errorMessage)
        .animation(.default, value: viewModel.dataModel.uri)

    }

//    var body: some View {
//        ZStack {
//            AppBackgroundView()
//            VStack(spacing: 16) {
//                VStack(spacing: 24) {
//                    Image(.qrWeb3)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                    HStack(spacing: 16) {
//                        Button {
//                            viewModel.presentQRCodeScanner()
//                        } label: {
//                            Image(.scanQrCode)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(height: 20)
//                                .padding(8)
//
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .tint(AssetsColors.gray2.color())
//                        .contentShape(.rect)
//                        
//                        VStack(spacing: 8) {
//                            Text("Scan dApp QR code")
//                                .font(.b1)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//
//                            Text("Open a dApp that supports WalletConnect, click here and scan the QR code.")
//                                .font(.b4)
//                                .foregroundStyle(.secondary)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//
//                        }
//                        .contentShape(.rect)
//                        .onTapGesture {
//                            viewModel.presentQRCodeScanner()
//                        }
//                    }
//                    .padding()
//                    .background(AssetsColors.gray1.color(), in: .rect(cornerRadius: 16))
//
//                    Text("Or paste dApp connection link")
//                        .font(.b2)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal)
//                    HStack(spacing: 16) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(AssetsColors.gray2.color())
//                                .frame(height: 42)
//                                .overlay {
//                                    Text("Enter address")
//                                        .font(.b4)
//                                        .foregroundStyle(.secondary)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        .opacity(viewModel.dataModel.uri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1 : 0)
//                                        .padding(.horizontal, 8)
//
//                                }
//                            TextField("", text: $viewModel.dataModel.uri)
//                                .font(.b2)
//                                .textFieldStyle(.plain)
//                                .padding(.horizontal, 8)
//                        }
//                    }
//                }
//                
//                Spacer()
////                BottomBanner(message: viewModel.ewManager?.errorMessage)
////                    .animation(.default, value: viewModel.ewManager?.errorMessage)
//
//                Text("Please enter address or scan QR")
//                    .font(.b4)
//                Button {
//                    viewModel.createConnection()
//                } label: {
//                    Text("Continue")
//                        .frame(maxWidth: .infinity, alignment: .center)
//                        .padding(8)
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(AssetsColors.gray2.color())
//                .background(AssetsColors.gray2.color(), in: .capsule)
//                .clipShape(.capsule)
//                .foregroundStyle(viewModel.dataModel.uri.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .primary)
//                .contentShape(.rect)
//            }
//            .padding()
//        }
//        .navigationTitle("Connect dApp")
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden()
//        .navigationBarItems(leading: CustomBackButtonView())
//        .onAppear() {
//            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager, coordinator: coordinator)
//        }
//        .fullScreenCover(isPresented: $viewModel.isQRPresented, content: {
//            NavigationStack {
//                GenericControllerNoEnvironments(uiViewType: QRCodeScannerViewController(delegate: viewModel)
//                )
//                .navigationTitle("Scan Connecion QR")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button {
//                            viewModel.isQRPresented = false
//                        } label: {
//                            Image(.close)
//                                .tint(.white)
//                        }
//                    }
//                }
//            }
//        })
//        .animation(.default, value: viewModel.ewManager?.errorMessage)
//        .animation(.default, value: viewModel.dataModel.uri)
//    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWWeb3ConnectionURI(dataModel: Web3DataModel.mock())
        }
    }
}
