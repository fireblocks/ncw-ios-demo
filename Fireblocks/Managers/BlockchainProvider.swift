//
//  BlockchainProvider.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 02/04/2025.
//
import Foundation

class BlockchainProvider {
    static let shared = BlockchainProvider()
    private init() {}
    
    private var blockchains: [Blockchain]?

    func getBlockchains() -> [Blockchain]? {
        if blockchains == nil {
            blockchains = convertToBlockchains()
        }
        return blockchains
    }
    
    func convertToBlockchains() -> [Blockchain]? {
        let jsonData = BlockchainDataContainer.blockchains.data(using: .utf8)!
        let decoder = JSONDecoder()

        do {
            let blockchains = try decoder.decode([Blockchain].self, from: jsonData)
            return blockchains
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }

    func getBlockchain(blockchainName: String) -> Blockchain? {
        return getBlockchains()?.first { $0.descriptor == blockchainName }
    }
}
