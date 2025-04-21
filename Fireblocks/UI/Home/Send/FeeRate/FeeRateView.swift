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
    @Environment(LoadingManager.self) var loadingManager
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif
    @State var viewModel: FeeRateViewModel
    
    init(viewModel: FeeRateViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if viewModel.getFees().isEmpty {
                ContentUnavailableView("Fees", systemImage: "", description: Text("Select Transaction Fee"))
                    .listRowBackground(Color.clear)
            }

            List {
                Section {
                    VStack(spacing: 16) {
                        Text(LocalizableStrings.transactionSpeed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.b2)
                        VStack(spacing: 4) {
                            ForEach(viewModel.getFees(), id: \.self.feeRateType) { fee in
                                HStack {
                                    Text(fee.getFeeName())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(.rect())
                                    Spacer()
                                    let feeData: String = viewModel.getFee(fee: fee)
                                    if let feeDouble = Double(feeData)?.formatFractionsAsString(fractionDigits: 6) {
                                        Text("~" + "\(feeDouble)" + " " + AssetsUtils.removeTestSuffix(viewModel.getSymbol()))
                                            .lineLimit(1)
                                    }
                                }
                                .padding()
                                .background(viewModel.selectedFee == nil ? Color.clear : fee.feeRateType == viewModel.selectedFee!.feeRateType ? AssetsColors.gray2.color() : Color.clear, in: .rect(cornerRadius: 8))
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
                    .padding(.vertical, 32)
                }
                .listRowBackground(AssetsColors.gray1.color())
                .listRowSeparator(.hidden)
            }
            .listRowSeparator(.hidden)
            .listStyle(.insetGrouped)
        }
        .safeAreaInset(edge: .bottom, content: {
            VStack(spacing: 8) {
                Button {
                    viewModel.transaction.fee = viewModel.selectedFee
                    viewModel.createTransaction()
                } label: {
                    Text(LocalizableStrings.continueButton)
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
        })
        .onAppear() {
            #if EW
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator, ewManager: ewManager)
            #else
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator)
            #endif
        }
        .navigationTitle(LocalizableStrings.fee)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .contentMargins(.top, 16)
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


