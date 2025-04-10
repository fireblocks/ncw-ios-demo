//
//  NFTCardDetails.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI

struct NFTCardDetails: View {
    var iconUrl: String?
    var blockchain: String?
    var blockchainSymbol: String?
    var nftName: String?
    var balance: String?
    var standard: String?
    var showBlockchainImage: Bool = false
    
    init(iconUrl: String?, blockchain: String?, blockchainSymbol: String?, nftName: String?, balance: String?, standard: String?, showBlockchainImage: Bool = false) {
        self.iconUrl = iconUrl
        self.blockchain = blockchain
        self.blockchainSymbol = blockchainSymbol
        self.nftName = nftName
        self.balance = balance
        self.standard = standard
        self.showBlockchainImage = showBlockchainImage
    }

    var body: some View {
        HStack(alignment: .center) {
            NFTIconCardView(iconUrl: iconUrl, blockchain: blockchainSymbol, showBlockchainImage: showBlockchainImage)
            VStack(alignment: .leading, spacing: 4) {
                Text(nftName ?? "")
                    .font(.b1)
                BulletSentenceView(textList: [blockchain, standard])
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            Spacer()
            BalanceView(balance: balance ?? "")
        }
    }
}

struct BalanceView: View {
    var balance: String

    var body: some View {
        if !balance.isEmpty {
            Text(balance)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black)
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NFTCardDetails(
        iconUrl: "https://stage-static.fireblocks.io/dev9/nft/media/aXBmczovL2JhZnliZWlkbzU0YmdscjVvMm5raHlicjdqb2Zmb2N3bmYybWYydWpod3lyc3h2dzQ1d2l0ZW5rd2txLzM",
        blockchain: "ETH",
        blockchainSymbol: "ETH",
        nftName: "NFT Name",
        balance: "1",
        standard: "ERC721",
        showBlockchainImage: true
    )
}
