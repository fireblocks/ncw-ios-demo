//
//  DeriveKeysView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 06/03/2024.
//

import SwiftUI
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

struct DeriveKeysView: View {
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                List {
                    ForEach(viewModel.sortedPrivateKeys(), id: \.self) { keyData in
                        if let algorithm = keyData.algorithm?.rawValue {
                            if let privateKey = keyData.privateKey {
                                Section(algorithm) {
                                    AssetCell(privateKey: privateKey, copyTextTitle: viewModel.getKeysTitle(algorithm: algorithm), copiedText: $viewModel.copiedText) {
                                        HStack {
                                            Text(viewModel.getKeysTitle(algorithm: algorithm))
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                        }
                                    }
                                }
                                .listRowSeparator(.hidden)
                            }
                            
                            if algorithm != Algorithm.MPC_EDDSA_ED25519.rawValue {
                                if let items = viewModel.items[algorithm] {
                                    ForEach(items, id: \.assetSummary) { item in
                                        if let privateKey = item.privateKey {
                                            let asset = item.assetSummary
                                            if let name = asset.asset?.name {
                                                Section {
                                                    AssetCell(privateKey: item.keyData?.data ?? "", copyTextTitle: name, copiedText: $viewModel.copiedText) {
                                                        DerivedAssetRow(asset: asset)
                                                    }
                                                    
                                                    if let wif = item.wif {
                                                        AssetCell(privateKey: wif, copyTextTitle: name, copiedText: $viewModel.copiedText) {
                                                            HStack {
                                                                Text("WIF")
                                                                    .foregroundStyle(.secondary)
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                }
                                                .listRowSeparator(.hidden)
                                            }

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .listRowSeparator(.hidden)
                .scrollContentBackground(.hidden)
                Spacer()
                
            }
            .padding(.vertical, 24)
            
            VStack(spacing: 0) {
                Spacer()
                Label {
                    Text("\(viewModel.copiedText ?? "") Key  Copied")
                } icon: {
                    Image(systemName: "checkmark")
                }
                .padding(16)
                .background(AssetsColors.gray1.color())
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                .opacity(viewModel.copiedText == nil ? 0 : 1)
                
            }
            .padding(.vertical, 24)
            
        }
        .animation(.default, value: viewModel.copiedText)
        .navigationTitle(viewModel.navigationBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
    }
}

struct AssetCell<Content: View>: View {
    let privateKey: String
    let copyTextTitle: String
    @Binding var copiedText: String?
    @State var isExposed: Bool = false
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                content
                Spacer()
                
                Image(uiImage: AssetsIcons.copy.getIcon())
                    .imageScale(.large)
                    .onTapGesture {
                        copiedText = copyTextTitle
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if copiedText == copyTextTitle {
                                copiedText = nil
                            }
                        }
                        UIPasteboard.general.string = privateKey
                        
                    }
            }
            
            MultilineSecureField(privateKey: privateKey, isExposed: isExposed)
        }
    }
}

struct MultilineSecureField: View {
    let privateKey: String
    @State var isExposed: Bool = false

    var body: some View {
        ZStack(alignment: .center) {
            Group {
                if isExposed {
                    // When exposed, show normal text with multiple lines
                    Text(privateKey)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.b1)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil) // Allow multiple lines
                } else {
                    // Custom secure field replacement with multiple lines
                    Text(String(repeating: "•", count: privateKey.count))
                        .font(.b1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil) // Allow multiple lines
                }
            }
            .padding(.trailing, 40) // Add trailing padding to prevent text overlap with icon
            
            // Eye icon positioned at center-right
            HStack {
                Spacer()
                Image(uiImage: isExposed ? AssetsIcons.eye.getIcon() : AssetsIcons.eyeCrossedOut.getIcon())
                    .imageScale(.large)
                    .onTapGesture {
                        withAnimation {
                            isExposed.toggle()
                        }
                    }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AssetsColors.gray2.color(), lineWidth: 1)
        )
    }
}

#Preview("DeriveKeysView") {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            DeriveKeysView(viewModel: PreviewViewModel())
        }
    }
}

// Preview view model
private class PreviewViewModel: DeriveKeysView.ViewModel {
    init() {
        // Create a mock FullKey using a decoder since we can't initialize it directly
        let mockKey = try! JSONDecoder().decode(FullKey.self, from: """
        {
            "algorithm": "\(Algorithm.MPC_ECDSA_SECP256K1.rawValue)",
            "privateKey": "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg"
        }
        """.data(using: .utf8)!)
        
        super.init(privateKeys: Set([mockKey]))
    }
}



