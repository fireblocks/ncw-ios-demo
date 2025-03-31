//
//  EWManagerMock.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 20/02/2025.
//

import Foundation
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

//@Observable
class EWManagerMock: EWManager {
    @MainActor
    override func presentErrorMessage() {
        
    }
    
    override func estimateOneTimeAddressTransaction(accountId: Int, assetId: String, destAddress: String, amount: String, feeLevel: FeeLevel?) async throws -> EstimatedTransactionFeeResponse {
        if let data = Mocks.Transaction.estimatedFee.data(using: .utf8) {
            if let estimatedFee: EstimatedTransactionFeeResponse = try GenericDecoder.decode(data: data) {
                return estimatedFee
            }
        }
        throw NSError()

    }
    
    override func createOneTimeAddressTransaction(accountId: Int, assetId: String, destAddress: String, amount: String, feeLevel: FeeLevel?) async throws-> CreateTransactionResponse {
        if let data = Mocks.Transaction.createTransactionResponse.data(using: .utf8) {
            if let transaction: CreateTransactionResponse = try GenericDecoder.decode(data: data) {
                return transaction
            }
        }
        
        throw NSError()

    }
    
    //MARK: - NFT -
    override func getNFT(id: String) async throws -> TokenResponse? {
        if let data = Mocks.NFT.tokenResponse.data(using: .utf8) {
            if let nfts: TokenResponse = try GenericDecoder.decode(data: data) {
                return nfts
            }
        }

        throw NSError()
    }
    
    override func getOwnedNFTs(
        allPages: Bool = true,
        blockchainDescriptor: BlockchainDescriptor? = nil,
        ncwAccountIds: [String]? = nil,
        ids: [String]? = nil,
        collectionIds: [String]? = nil,
        pageCursor: String? = nil,
        pageSize: Int? = nil,
        sort: [GetOwnershipTokensSort]? = nil,
        order: Order? = nil,
        status: TokensStatus? = nil,
        search: String? = nil,
        spam: TokensSpam? = nil
    ) async throws -> PaginatedResponse<TokenOwnershipResponse> {
        if let data = Mocks.NFT.getOwnedResponse.data(using: .utf8) {
            if let nfts: PaginatedResponse<TokenOwnershipResponse> = try? GenericDecoder.decode(data: data) {
                return nfts
            }
        }

        throw NSError()
    }

    override func listOwnedCollections(
        allPages: Bool = true,
        pageCursor: String? = nil,
        pageSize: Int? = nil,
        sort: [ListOwnedTokensSort]? = nil,
        order: Order? = nil,
        status: TokensStatus? = nil,
        search: String? = nil
    ) async throws -> PaginatedResponse<TokenOwnershipResponse> {
        throw NSError()
    }

    override func listOwnedAssets(
        allPages: Bool = true,
        pageCursor: String? = nil,
        pageSize: Int? = nil,
        sort: [ListOwnedTokensSort]? = nil,
        order: Order? = nil,
        status: TokensStatus? = nil,
        search: String? = nil,
        spam: TokensSpam? = nil
    ) async throws -> PaginatedResponse<TokenOwnershipResponse> {
        throw NSError()
    }

    //MARK: - Web3 -
    override func getConnections(allPages: Bool = true, pageCursor: String? = nil, order: Order? = nil, filter: Web3Filter? = nil, sort: Web3ConnectionSort? = nil, pageSize: Int? = nil) async throws -> PaginatedResponse<Web3Connection> {

        if let data = Mocks.Connections.getResponse.data(using: .utf8) {
            if let connections: PaginatedResponse<Web3Connection> = try GenericDecoder.decode(data: data) {
                return connections
            }
        }
        
        throw NSError()
    }
    
    override func createConnection(feeLevel: Web3ConnectionFeeLevel, uri: String, ncwAccountId: Int, chainIds: [String]? = nil) async throws -> CreateWeb3ConnectionResponse {
        if let data = Mocks.Connections.create.data(using: .utf8) {
            if let asset: CreateWeb3ConnectionResponse = try GenericDecoder.decode(data: data) {
                return asset
            }
        }
        
        throw NSError()
    }
    
    override func submitConnection(id: String, approve: Bool) async throws -> String {
        return "true"
    }

    override func removeConnection(id: String) async throws -> String {
        return "true"
    }
    
    override func getTransactionById(txId: String) async throws -> TransactionResponse {
        return Mocks.Transaction.getResponse()
    }

    
    func getItem<T: Codable>(type: T.Type, item: String) -> T? {
        if let data = item.data(using: .utf8) {
            if let result: T =  try? GenericDecoder.decode(data: data) {
                return result
            }
        }
        return nil
    }
}


@Observable
class EWManagerMock1: EWManager {
    var walletId = Constants.walletId

//    override init() {
//        super.init()
//    }

    override func createAccount() async -> Int? {
        return 0
    }
    
    override func fetchAllAccounts() async -> [Account] {
        if let data = Mocks.Account.response.data(using: .utf8) {
            if let accounts: [Account] = try? GenericDecoder.decode(data: data) {
                return accounts
            }
        }
        return []
    }
    
    override func fetchAllAccountAssets(accountId: Int) async -> [Asset] {
        if let data = Mocks.AssetMock.response.data(using: .utf8) {
            if let asset: Asset = try? GenericDecoder.decode(data: data) {
                return [asset]
            }
        }
        return []
    }
    
    
    override func fetchAllSupportedAssets() async -> [Asset] {
        if let data = Mocks.AssetMock.response.data(using: .utf8) {
            if let asset: Asset = try? GenericDecoder.decode(data: data) {
                return [asset]
            }
        }
        return []
    }
    
    override func getAssetBalance(assetId: String, accountId: Int) async throws -> AssetBalance {
        if let data = Mocks.GetAssetBalance.response.data(using: .utf8) {
            if let asset: AssetBalance = try GenericDecoder.decode(data: data) {
                return asset
            }
        }
        throw NSError()
    }
    
    override func fetchAllAccountAssetAddresses(assetId: String, accountId: Int) async -> [AddressDetails] {
        if let data = Mocks.GetAssetAddresses.response.data(using: .utf8) {
            if let asset: PaginatedResponse<AddressDetails> = try? GenericDecoder.decode(data: data) {
                return asset.data ?? []
            }
        }
        return []
    }
    
    override func getConnections(allPages: Bool = true, pageCursor: String? = nil, order: Order? = nil, filter: Web3Filter? = nil, sort: Web3ConnectionSort? = nil, pageSize: Int? = nil) async throws -> PaginatedResponse<Web3Connection> {

        if let data = Mocks.Connections.getResponse.data(using: .utf8) {
            if let asset: PaginatedResponse<Web3Connection> = try GenericDecoder.decode(data: data) {
                return asset
            }
        }
        
        throw NSError()
    }
    
    override func removeConnection(id: String) async throws -> String {
        return "true"
    }
    
    func getItem<T: Codable>(type: T.Type, item: String) -> T? {
        if let data = item.data(using: .utf8) {
            if let result: T =  try? GenericDecoder.decode(data: data) {
                return result
            }
        }
        return nil
    }
}

class EWManagerMockNoAccount: EWManagerMock1 {
    override func createAccount() async -> Int? {
        return nil
    }
    
    override func fetchAllAccounts() async -> [Account] {
        return []
    }
}

class EWManagerMockNoAssets: EWManagerMock1 {
    override func fetchAllAccountAssets(accountId: Int) async -> [Asset] {
        return []
    }
}

class AssetListViewModelMock: AssetListViewModel {
    override func getAsset(by assetId: String) -> Asset? {
        return Mocks.AssetMock.getAsset()

    }
    
    override func getAssetSummary() -> [AssetSummary] {
        return [AssetSummary(asset: Mocks.AssetMock.getAsset())]
    }

    override func fetchAssets() {
        self.assetsSummary = [AssetSummary(asset: Mocks.AssetMock.getAsset())]
    }
}



