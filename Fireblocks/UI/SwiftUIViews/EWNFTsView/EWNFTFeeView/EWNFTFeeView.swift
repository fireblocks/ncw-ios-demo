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
                            Text("Select fee speed")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.b2)
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
                        .padding()
                    }
                    .background(AssetsColors.gray1.color(), in: .rect)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
//                BottomBanner(message: viewModel.ewManager?.errorMessage)
//                    .animation(.default, value: viewModel.ewManager?.errorMessage)
                Button {
                    viewModel.createTransaction()
                } label: {
                    Text("Create transaction")
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
            .background()
        })
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, ewManager: ewManager, coordinator: coordinator)
        }
        .animation(.default, value: viewModel.dataModel.feeLevel)
        .navigationTitle("NFT Transfer")
        .navigationBarTitleDisplayMode(.inline)
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


