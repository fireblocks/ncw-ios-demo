//
//  EWNFTRow.swift
//  EW-dev
//
//  Created by Dudi Shani-Gabay on 26/02/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

struct EWNFTCard: View {
    let isRow: Bool
    @State var viewModel: ViewModel
    
    init(token: TokenOwnershipResponse, isRow: Bool = true) {
        self.isRow = isRow
        _viewModel = State(initialValue: ViewModel(token: token))

    }

    var body: some View {
        if isRow {
            let nftToken = viewModel.token
            let blockchain = nftToken.blockchainDescriptor?.rawValue
            NFTCardDetails(iconUrl: nftToken.media?.first?.url,
                           blockchain: AssetsUtils.getBlockchainDisplayName(blockchainName: blockchain),
                           blockchainSymbol: blockchain,
                           nftName: nftToken.name,
                           balance: nftToken.balance,
                           standard: nftToken.standard,
                           showBlockchainImage: true
            )
        } else {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    image
                    .padding(.top, 16)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 104)
                .background(viewModel.uiimage?.averageColor)

                VStack(alignment: .leading, spacing: 16) {
                    tokenId
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.h4)
                    name
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.b2)
                    HStack(spacing: 4) {
                        blockchainDescriptor
                        Text("∙")
                        standard
                        Spacer()
                    }
                    .font(.b4)
                    .foregroundStyle(.secondary)

                }
                .padding()
                .background(AssetsColors.gray2.color())
            }
            .contentShape(Rectangle())
            .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var image: some View {
        if let image = viewModel.image {
            image.resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "globe")
                .frame(width: 64, height: 64)
                .clipShape(.rect(cornerRadius: 8))

        }
    }
    
    @ViewBuilder
    private var name: some View {
        if let name = viewModel.token.name?.capitalized {
            Text(name)
        }
    }

    @ViewBuilder
    private var tokenId: some View {
        if let tokenId = viewModel.token.tokenId {
            Text(tokenId)
        }
    }

    @ViewBuilder
    private var blockchainDescriptor: some View {
        if let blockchainDescriptor = viewModel.token.blockchainDescriptor?.rawValue {
            Text(blockchainDescriptor)
        }
    }

    @ViewBuilder
    private var standard: some View {
        if let standard = viewModel.token.standard {
            Text(standard)
        }
    }


}

#Preview("row") {
    EWNFTCard(token: EWManagerMock().getItem(type: TokenOwnershipResponse.self, item: Mocks.NFT.item)!, isRow: true)
}

#Preview("card") {
    EWNFTCard(token: EWManagerMock().getItem(type: TokenOwnershipResponse.self, item: Mocks.NFT.item)!, isRow: false)
}

