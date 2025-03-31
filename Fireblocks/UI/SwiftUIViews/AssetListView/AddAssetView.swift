//
//  AddAssetView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 28/02/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct AddAssetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    #if EW
    @Environment(EWManager.self) var ewManager
    #endif

    @Binding var selectedAsset: AssetSummary?
    @State var viewModel = AddAssetsViewModel()
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            if viewModel.searchResults.isEmpty {
                ContentUnavailableView("Assets", systemImage: "magnifyingglass", description: Text("No assets found"))
                    .listRowBackground(Color.clear)
            }

            List {
                ForEach(viewModel.searchResults, id: \.asset) { asset in
                    Section {
                        AssetRow(asset: asset.asset)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.didSelect(asset: asset)
                                }
                            }
                            .listRowBackground(asset.isSelected ? Color.black.opacity(0.2) : AssetsColors.gray1.color())
                            .animation(.default, value: asset.isSelected)
                    }
                }
            }
            .listSectionSpacing(.compact)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 16)

        }
        .navigationTitle("Select Asset")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        .searchable(text: $viewModel.searchText)
        .safeAreaInset(edge: .bottom, content: {
            HStack {
                Button {
                    viewModel.createAsset()
                } label: {
                    HStack(spacing: 8) {
                        Spacer()
                        Image(.plus)
                        Text("Add asset")
                        Spacer()
                    }
                    .font(.b2)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
                .background(AssetsColors.gray2.color(), in: .capsule)
                .clipShape(.capsule)
                .contentShape(.rect)
                .disabled(viewModel.getSelectedCount() > 0 ? false : true)
            }
            .padding()
            .background(.black)


        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(.close)
                        .tint(.white)
                }
            }
        }
        .animation(.default, value: viewModel.getSelectedCount())
        .animation(.default, value: viewModel.searchResults)
        .onAppear() {
            #if EW
            viewModel.setup(ewManager: ewManager, loadingManager: loadingManager)
            #else
            viewModel.setup(loadingManager: loadingManager, deviceId: fireblocksManager.deviceId)
            #endif
        }
        .onChange(of: viewModel.selectedAsset) { oldValue, newValue in
            if let asset = newValue?.asset {
                selectedAsset = asset
                dismiss()
            }
        }
        .onChange(of: viewModel.searchText) { oldValue, newValue in
            viewModel.searchDidChange()
        }
    }
}

//#Preview {
//    AddAssetView(selectedAsset: <#T##Asset?#>, viewModel: <#T##arg#>)
//}
