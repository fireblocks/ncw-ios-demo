//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 15/04/2025.
//
import SwiftUI

struct SupportedBlockchainsListItemView: View {
    let chainIds: [String]
    
    init(chainIds: [String]) {
        self.chainIds = chainIds
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(chainIds.enumerated()), id: \.element) { index, blockchain in
                let blockchainDisplayName = BlockchainProvider.shared.getBlockchain(blockchainName: blockchain)?.displayName ?? blockchain
                
                HStack(alignment: .center, spacing: 0) {
                    if index == 0 {
                        Text("Supported blockchains")
                            .font(.b2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .frame(width: Dimens.cellTitleWidth, alignment: .leading)
                    } else {
                        Spacer()
                            .frame(width: Dimens.cellTitleWidth)
                    }
                    
                    VStack(spacing: 0) {
                        if index > 0 {
                            Divider()
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            BlockchainIconView(blockchainSymbol: blockchain)
                            
                            Text(blockchainDisplayName)
                                .font(.b2)
                                .padding(.leading, 8)
                        }
                        .frame(height: 44) // Set an appropriate height for the row
                        .frame(maxWidth: .infinity, alignment: .leading) // This aligns HStack content to the leading edge
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // This aligns the VStack to the leading edge
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Dimens.paddingLarge)
    }
}

// Preview provider
#Preview {
    let chainIds = ["ETH_TEST5", "ETH_TEST6", "BTC", "ETH"]
    SupportedBlockchainsListItemView(chainIds: chainIds)
}
