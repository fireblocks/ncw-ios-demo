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
    @EnvironmentObject var fireblocksManager: FireblocksManager
    let transaction: FBTransaction
    let assetRowViewModel: AssetRowViewModel
    var transferInfo: TransferInfo?
    var nftWrapper: NFTWrapper?

    init(transaction: FBTransaction, transferInfo: TransferInfo?) {
        self.transaction = transaction
        self.assetRowViewModel = AssetRowViewModel(asset: transaction.asset)
        self.transferInfo = transferInfo
        #if EW
        if let transferInfo, transferInfo.isNFT() {
            self.nftWrapper = NFTViewModel.shared.getNFTWrapper(id: transferInfo.assetId)
        }
        #endif
    }
    
    func getNumberOfNFTs(balance: String) -> String {
        let numberOfNfts = balance == "1" ? "1 NFT" : "\(balance) NFTs"
        return numberOfNfts
    }
    
    var body: some View {
        let title = transferInfo?.getSendOrReceiveTitle(walletId: fireblocksManager.walletId) ?? ""
        if (nftWrapper != nil) {
            let balance = transaction.amountToSend.formatted()
            DetailsListItemView(
                title: title,
                contentText: getNumberOfNFTs(balance: balance)
            )
        } else {
            DetailsListItemView(
                title: title,
                contentText: transaction.amountToSend.formatted() + " " + (transaction.asset.asset?.symbol ?? ""),
                subContent: "$" + transaction.price.formatted()
            )
        }
        
        let asset = transaction.asset
        HStack(spacing: 0) {
            if (nftWrapper != nil) {
                NFTCardDetails(iconUrl: nftWrapper?.iconUrl,
                               blockchain: nftWrapper?.blockchain,
                               blockchainSymbol: nftWrapper?.blockchainSymbol,
                               nftName: nftWrapper?.name,
                               balance: nftWrapper?.balance,
                               standard: nftWrapper?.standard,
                               showBlockchainImage: true
                )
            } else {
                CryptoIconCardView(asset: asset, showBlockchainImage: true)
                    .padding(.trailing, Dimens.paddingDefault)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        let title = AssetsUtils.getAssetTitleText(asset: asset.asset)
                        Text(title)
                            .font(.b1)
                        Spacer()
                    }
                    Text(asset.asset?.name ?? "")
                        .font(.b2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.leading, Dimens.cellTitleWidth + Dimens.paddingLarge + Dimens.paddingSmall)
        .padding(.bottom, Dimens.paddingDefault)
        
        
    }
}

#Preview {
#if EW
    let transferInfo: TransferInfo = TransferInfo.toTransferInfo(response: Mocks.Transaction.getResponse_ETH_TEST5())
    let transaction: FBTransaction = transferInfo.toTransaction(assetListViewModel: AssetListViewModelMock())!
    SpinnerViewContainer {
        VStack {
            TransactionHeaderView(
                transaction: transaction,
                transferInfo: transferInfo
            )}
    }
    .environmentObject(FireblocksManager.shared)
#endif
}
