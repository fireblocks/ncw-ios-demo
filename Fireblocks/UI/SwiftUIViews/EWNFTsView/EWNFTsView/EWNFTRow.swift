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

struct EWNFTRow: View {
    @State var viewModel: ViewModel
    
    init(token: TokenOwnershipResponse) {
        _viewModel = State(initialValue: ViewModel(token: token))

    }

    var body: some View {
        HStack(spacing: 16) {
            if let image = viewModel.image {
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 8))
                    
            } else {
                Image(systemName: "globe")
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 8))

            }
//            val nftName = nft.name ?: "" // sword
//            val blockchain = nft.blockchainDescriptor?.name ?: "" //ETH_TEST5
//            val standard = nft.standard ?: "" // ERC1155
//            val tokenId = nft.tokenId ?: ""
//            val iconUrl = nft.media?.firstOrNull()?.url

            VStack(spacing: 8) {
                HStack {
                    if let name = viewModel.token.name {
                        Text(name)
                    }
                    Spacer()
                    if let tokenId = viewModel.token.tokenId {
                        Text(tokenId)
                    }
                }
                .font(.b1)
                HStack {
                    if let blockchainDescriptor = viewModel.token.blockchainDescriptor?.rawValue {
                        Text(blockchainDescriptor)
                    }
                    Spacer()
                    if let standard = viewModel.token.standard {
                        Text(standard)
                    }
                }
                .font(.b4)
                .foregroundStyle(.secondary)

            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}

#Preview {
    EWNFTRow(token: EWManagerMock().getItem(type: TokenOwnershipResponse.self, item: Mocks.NFT.item)!)
}
