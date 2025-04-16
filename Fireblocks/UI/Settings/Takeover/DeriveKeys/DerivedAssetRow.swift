//
//  DerivedAssetRow.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 06/03/2024.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct DerivedAssetRow: View {
    let asset: AssetSummary
    @State var viewModel: ViewModel
    
    init(asset: AssetSummary) {
        self.asset = asset
        _viewModel = State(initialValue: ViewModel(symbol: asset.asset?.symbol, iconUrl: asset.iconUrl))
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                if let assetImage = viewModel.assetImage {
                    Group {
                        assetImage
                    }
                    .padding(4)
                }
            }
            .frame(width: 32, height: 32)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))

            if let name = asset.asset?.name {
                Text(name)
                    .font(.b1)
                    .multilineTextAlignment(.leading)
            }

        }
    }
}

//#Preview {
//    DerivedAssetRow(asset: Ass)
//}
