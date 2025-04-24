//
//  SendToView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 23/04/2025.
//

import SwiftUI

struct SendToView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif

    @State var viewModel: SendToViewModel
    
    init(viewModel: SendToViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                List {
                    Section {
                        VStack(spacing: 0) {
                            AssetRow(asset: viewModel.transaction.asset, titleAmount: viewModel.getAmountToSendAsString(), subTitleAmount: viewModel.getPriceAsString())
                                .padding()
                        }
                    }
                    .background(AssetsColors.gray1.color(), in: .rect)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                    Section {
                        VStack(spacing: 16) {
                            Text(LocalizableStrings.address)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.b2)

                            HStack(spacing: 0) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AssetsColors.gray2.color())
                                        .frame(height: 48)
                                        .overlay {
                                            Text(LocalizableStrings.address_hint)
                                                .font(.b4)
                                                .foregroundStyle(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .opacity(viewModel.isAddressValid() ? 0 : 1)
                                                .padding(.horizontal, 8)

                                        }
                                    TextField("", text: $viewModel.address)
                                        .font(.b2)
                                        .textFieldStyle(.plain)
                                        .padding(.horizontal, 8)
                                }
                                .padding(.trailing, 12)
                                Button {
                                    viewModel.presentQRCodeScanner()
                                } label: {
                                    Image(.scanQrCode)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 20)
                                        .padding(7)

                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AssetsColors.gray2.color())
                                .contentShape(.rect)
                            }
                        }
                    }
                    .listRowBackground(AssetsColors.gray1.color())
                    .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
                }
                .scrollContentBackground(.hidden)
                .padding(.bottom, 1)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
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
                .disabled(viewModel.isAddressValid() == false)

            }
            .padding()
        })
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.address)
        .navigationTitle("Recipient")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .contentMargins(.top, 16)
        .fullScreenCover(isPresented: $viewModel.isQRPresented, content: {
            NavigationStack {
                GenericControllerNoEnvironments(uiViewType: QRCodeScannerViewController(delegate: viewModel)
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
    NavigationContainerView() {
        SpinnerViewContainer {
            SendToView(viewModel: SendToViewModel(transaction: FBTransaction.mock))
        }
    }
}
