//
//  CryptoIconCard.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 03/04/2025.
//
import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct CryptoIconCardView: View {
    var asset: AssetSummary
    var showBlockchainImage: Bool = false
    @State var assetRowViewModel: AssetRowViewModel
    var imageSize = Dimens.imageSize
    
    init(asset: AssetSummary, showBlockchainImage: Bool = false, imageSize: Double = Dimens.imageSize) {
        self.asset = asset
        self.showBlockchainImage = showBlockchainImage
        self.imageSize = imageSize
        _assetRowViewModel = State(initialValue: AssetRowViewModel(asset: asset))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.clear)
                .frame(width: imageSize, height: imageSize)
                .overlay {
                    if let image = assetRowViewModel.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageSize, height: imageSize)
                            .overlay(alignment: .bottomTrailing) {
                                if (showBlockchainImage) {
                                    if let blockchainImage = assetRowViewModel.blockchainImage {
                                        blockchainImage
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 1)
                                            }
                                        //                                    .opacity(blockchainImage != nil ? 1 : 0)
                                    }
                                }
                            }
                    }
                }
                .animation(.default, value: assetRowViewModel.image)
        }
    }
}

#Preview {
    #if EW
        let transaction = TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5()).toTransaction(assetListViewModel: AssetListViewModelMock())!
        CryptoIconCardView(asset: transaction.asset, showBlockchainImage: true)
    #endif
}
