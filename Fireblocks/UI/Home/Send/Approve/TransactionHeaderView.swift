//
//  TransactionHeaderView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 03/03/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct TransactionHeaderView: View {
    let transaction: FBTransaction
    let assetRowViewModel: AssetRowViewModel
    var transferInfo: TransferInfo?
    
    init(transaction: FBTransaction, transferInfo: TransferInfo?) {
        self.transaction = transaction
        self.assetRowViewModel = AssetRowViewModel(asset: transaction.asset)
        self.transferInfo = transferInfo
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let image = assetRowViewModel.image {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AssetsColors.gray2.color())
                    .frame(width: 46, height: 46)
                    .overlay {
                        image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    }
            }
            
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 4) {
                    Text(transaction.amountToSend.formatted())
                    Text(transaction.asset.asset?.symbol ?? "")
                    Spacer()
                }
                .font(.b1)
                
                HStack(spacing: 0) {
                    Group {
                        Text("$")
                        Text(transaction.price.formatted())
                    }
                    .font(.b4)
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }

            Spacer()
            if let transferInfo {
                TransactionStatusView(transferInfo: transferInfo)
            }

        }
    }
}

//#Preview {
//    TransactionHeaderView()
//}
