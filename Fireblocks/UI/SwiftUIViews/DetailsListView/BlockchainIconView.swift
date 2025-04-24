//
//  BlockchainIconView.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 15/04/2025.
//
import SwiftUI

struct BlockchainIconView: View {
    var blockchainSymbol: String
    @State var viewModel: ViewModel
    
    init(blockchainSymbol: String) {
        self.blockchainSymbol = blockchainSymbol
        _viewModel = State(initialValue: ViewModel(blockchainSymbol: blockchainSymbol))
    }

    var body: some View {
        HStack(spacing: 0) {
            if let blockchainImage = viewModel.blockchainImage {
                blockchainImage
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
            }
        }
    }
}

#Preview {
    BlockchainIconView(
        blockchainSymbol: "ETH"
    )
    .background(Color.black)
}
