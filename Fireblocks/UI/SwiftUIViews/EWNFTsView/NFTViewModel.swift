//
//  NFTViewModel.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI

class TransfersSequence: AsyncSequence {
    let transfers: [TransferInfo]

    init(transfers: [TransferInfo]) {
        self.transfers = transfers
    }
    
    struct AsyncIterator : AsyncIteratorProtocol {
        let transfers: [TransferInfo]
        private var currentIndex = 0
        
        init(transfers: [TransferInfo], currentIndex: Int = 0) {
            self.transfers = transfers
            self.currentIndex = currentIndex
        }
        
        mutating func next() async -> TransferInfo? {
            guard !Task.isCancelled else {
                return nil
            }
            
            if currentIndex >= transfers.count {
                return nil
            }
            
            let result = transfers[currentIndex]
            currentIndex += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(transfers: transfers)
    }

    typealias Element = TransferInfo
}

@Observable
class NFTViewModel {
    static let shared = NFTViewModel()
    
    var ewMAnager = EWManager.shared //TODO: inject ewManager
    var nftWrappers: [NFTWrapper] = []
    
    
    func loadNFTs(transfers: [TransferInfo]) {
        let allNFTTransfers = transfers.filter { $0.isNFT() }
        let nftTransfers = allNFTTransfers.filter { transfer in
            !nftWrappers.contains { $0.id == transfer.assetId }
        }
        Task {
            do {
                if nftTransfers.count > 0 {
                    let sequence = TransfersSequence(transfers: nftTransfers)
                    for try await transfer in sequence {
                        await withThrowingTaskGroup(of: ([NFTWrapper]).self) { [weak self] group in
                            guard let self else { return }
                            group.addTask {
                                let result = try await self.ewMAnager.getNFT(id: transfer.assetId)
                                
                                if let result {
                                    let blockchain = result.blockchainDescriptor?.rawValue
                                    let nftWrapper = NFTWrapper(
                                        id: result.id,
                                        name: result.name,
                                        collectionName: result.collection?.name,
                                        iconUrl: result.media?.first?.url,
                                        blockchain: AssetsUtils.getBlockchainDisplayName(blockchainName: blockchain),
                                        blockchainSymbol: blockchain,
                                        standard: result.standard
                                    )
                                    print("WRAPPER ADDED: \(nftWrapper)")
                                    self.nftWrappers.append(nftWrapper)
                                }
                                
                                return self.nftWrappers
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func getNFTWrapper(id: String) -> NFTWrapper? {
        return nftWrappers.first { $0.id == id }
    }
    
}
