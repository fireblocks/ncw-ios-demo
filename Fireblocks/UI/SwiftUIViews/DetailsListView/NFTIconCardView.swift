//
//  NFTIconCard.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//
import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct NFTIconCardView: View {
    var iconUrl: String?
    var blockchain: String?
    var showBlockchainImage: Bool = false
    @State var viewModel: ViewModel
    var imageSize = Dimens.imageSize
    
    init(iconUrl: String?, blockchain: String?, showBlockchainImage: Bool = false) {
        _viewModel = State(initialValue: ViewModel(iconUrl: iconUrl, blockchain: blockchain))
        self.showBlockchainImage = showBlockchainImage
    }

    var body: some View {
        VStack() {
            HStack(spacing: 0) {
                image
            }
            .frame(width: 64, height: 64)
            .background(viewModel.uiimage?.averageColor)
            .clipShape(.rect(cornerRadius: 12))
            .contentShape(Rectangle())
            .overlay(alignment: .bottomTrailing) {
                if (showBlockchainImage) {
                    if let blockchainImage = viewModel.blockchainImage {
                        blockchainImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.black, lineWidth: 1)
                            }
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    private var image: some View {
        if let image = viewModel.image {
            image.resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(.nftPlaceholder)
                .frame(width: 48, height: 48)
                .clipShape(.rect(cornerRadius: 8))

        }
    }
}

#Preview() {
    NFTIconCardView(iconUrl: "", blockchain: "ETH")
}
