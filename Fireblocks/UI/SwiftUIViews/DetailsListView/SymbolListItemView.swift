//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//
import SwiftUI

struct SymbolListItemView: View {
    var title: String
    var blockchain: String
    var blockchainSymbol: String
    @State var viewModel: ViewModel
    
    init(title: String, blockchain: String, blockchainSymbol: String) {
        self.title = title
        self.blockchain = blockchain
        self.blockchainSymbol = blockchainSymbol
        _viewModel = State(initialValue: ViewModel(blockchainSymbol: blockchainSymbol))
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.b2)
                .foregroundColor(.secondary)
                .frame(width: Dimens.cellTitleWidth, alignment: .leading)
                .padding(.trailing, Dimens.paddingSmall)
            
            if let blockchainImage = viewModel.blockchainImage {
                blockchainImage
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
            }
            Text(blockchain)
                .font(.b2)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Dimens.detailsListItemHeight)
        .padding(.horizontal, Dimens.paddingLarge)
    }
}

#Preview {
    SymbolListItemView(
        title: "Blockchain",
        blockchain: "Ethereum Testnet Sepolia",
        blockchainSymbol: "ETH"
    )
    .background(Color.black)
}
