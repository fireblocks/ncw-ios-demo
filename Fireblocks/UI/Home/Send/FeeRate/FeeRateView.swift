//
//  FeeRateView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/03/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct FeeRateView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    @State var viewModel: FeeRateViewModel
    
    init(viewModel: FeeRateViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
//            AppBackgroundView()
            if viewModel.getFees().isEmpty {
                ContentUnavailableView("Fees", systemImage: "", description: Text("Select Transaction Fee"))
                    .listRowBackground(Color.clear)
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Speed")
                    Spacer()
                    Text("Fee")
                }
                .padding()
                List {
                    Section {
                        VStack {
                            ForEach(viewModel.getFees(), id: \.self.feeRateType) { fee in
                                HStack {
                                    Text(fee.getFeeName())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(.rect())
                                    Spacer()
                                    if let feeDouble = Double(viewModel.getFee(fee: fee))?.formatFractions(fractionDigits: 6) {
                                        Text("~" + "\(feeDouble)" + " " + viewModel.getSymbol())
                                    }
                                }
                                .padding()
                                .background(viewModel.selectedFee == nil ? Color.clear : fee.feeRateType == viewModel.selectedFee!.feeRateType ? AssetsColors.gray2.color() : Color.clear, in: .rect)
                                .foregroundStyle(viewModel.selectedFee == nil ? .secondary : fee.feeRateType == viewModel.selectedFee!.feeRateType ? Color.white : .secondary)
                                .contentShape(.rect)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.selectedFee = fee
                                    }
                                }

                            }
                            
                        }
                    }
                    .background(AssetsColors.gray1.color(), in: .rect)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                }
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
                Button {
                    viewModel.transaction.fee = viewModel.selectedFee
                    viewModel.createTransaction()
                } label: {
                    Text("Create transaction")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
                .disabled(viewModel.selectedFee == nil || viewModel.getFeesCount() == 0)
                .background(AssetsColors.gray2.color(), in: .capsule)
                .clipShape(.capsule)
                .contentShape(.rect)

            }
            .padding()
            .background()
        })
        .onAppear() {
            #if EW
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator, ewManager: ewManager)
            #else
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator)
            #endif
        }
        .navigationTitle("Select Fee")
        .navigationBarTitleDisplayMode(.inline)
        .contentMargins(.top, 0)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())

    }
}

#Preview {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            FeeRateView(viewModel: FeeRateViewModel(transaction: FBTransaction.mock))
        }
    }
    #endif
}


