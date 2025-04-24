//
//  EWNFTFeeView.swift
//  Fireblocks
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

struct EWNFTFeeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @Environment(EWManager.self) var ewManager
    @State var viewModel: ViewModel
    
    init(dataModel: NFTDataModel) {
        _viewModel = State(initialValue: ViewModel(dataModel: dataModel))
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if viewModel.dataModel.token != nil {
                List {
                    Section {
                        VStack(spacing: 16) {
                            Text(LocalizableStrings.transactionSpeed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.b2)
                            VStack(spacing: 4) {
                                ForEach(FeeLevel.allCases, id: \.self) { fee in
                                    Text(viewModel.speed(level: fee))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .contentShape(.rect())
                                        .background(fee == viewModel.dataModel.feeLevel ? AssetsColors.gray2.color()  : Color.clear, in: .rect(cornerRadius: 8))
                                        .foregroundStyle(fee == viewModel.dataModel.feeLevel ? .white : .secondary)
                                        .onTapGesture {
                                            viewModel.dataModel.feeLevel = fee
                                        }
                                }
                            }
                        }
                        .padding(.vertical, 32)
                    }
                    .listRowBackground(AssetsColors.gray1.color())
                    .listRowSeparator(.hidden)
                }
                .listRowSeparator(.hidden)
                .listStyle(.insetGrouped)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
                Button {
                    viewModel.createTransaction()
                } label: {
                    Text(LocalizableStrings.continueButton)
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
        })
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.dataModel.feeLevel)
        .navigationTitle(LocalizableStrings.fee)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .contentMargins(.top, 16)

    }
}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWNFTFeeView(dataModel: NFTDataModel.mock())
        }
    }
}


