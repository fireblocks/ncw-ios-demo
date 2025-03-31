//
//  TransferRow.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/03/2025.
//

import SwiftUI

struct TransferRow: View {
    @EnvironmentObject var fireblocksManager: FireblocksManager
    let transferInfo: TransferInfo
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Text(transferInfo.getReceiverRowTitle(walletId: fireblocksManager.walletId))
                Text(transferInfo.isNFT() ? "NFT" : transferInfo.blockChainName)
                Text(transferInfo.blockChainName)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AssetsColors.gray2.color(), in: .capsule)
                    .font(.b4)
                    .foregroundColor(.secondary)
                Spacer()
                Text(transferInfo.amount.formatted())

            }
            
            HStack {
                TransactionStatusView(transferInfo: transferInfo)
                Spacer()
                Text("$" + transferInfo.price.formatted())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        TransferRow(transferInfo: TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()))
            .environmentObject(FireblocksManager.shared)
    }
    .listStyle(.plain)
    .padding()
}
