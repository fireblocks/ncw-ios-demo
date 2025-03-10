//
//  EWManager.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 22/09/2024.
//

import Foundation

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif


//protocol EWManagerAPIProtocol {
//    func getConnections(allPages: Bool, pageCursor: String?, order: Order?, filter: String?, sort: Web3ConnectionSort?, pageSize: Int?) async throws -> PaginatedResponse<Web3Connection>
//    func createConnection(feeLevel: Web3ConnectionFeeLevel, uri: String, ncwAccountId: Int, chainIds: [String]?) async throws -> CreateWeb3ConnectionResponse
//    func submitConnection(id: String, approve: Bool) async throws -> String
//    func removeConnection(id: String) async throws -> String
//}
//
//extension EWManagerAPIProtocol {
//    func getConnections(allPages: Bool = true, pageCursor: String? = nil, order: Order? = nil, filter: String? = nil, sort: Web3ConnectionSort? = nil, pageSize: Int? = nil) async -> PaginatedResponse<Web3Connection>? { return nil }
//    func createConnection(feeLevel: Web3ConnectionFeeLevel, uri: String, ncwAccountId: Int, chainIds: [String]? = nil) async -> CreateWeb3ConnectionResponse? { return nil }
//}

@Observable
class EWManager: Hashable {
    static func == (lhs: EWManager, rhs: EWManager) -> Bool {
        return lhs.authClientId == rhs.authClientId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(authClientId)
    }

    static let shared: EWManager = EWManager()
    var mockManager: EWManagerMock?
    
    init(mockManager: EWManagerMock? = nil) {
        self.mockManager = mockManager
        self.instance = try? initialize()
    }
    
    var instance: EmbeddedWallet?
    let authClientId = EnvironmentConstants.authClientId
    let options = EmbeddedWalletOptions(env: .DEV9, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
    var keyStorageDelegate: KeyStorageProvider?
//    var walletId: String?
//    var deviceId: String?

    var errorMessage: String? {
        didSet {
            if errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.errorMessage = nil
                }
            }
        }
    }
    
    @MainActor
    func setErrorMessage(_ message: String?) {
        errorMessage = message
        presentErrorMessage()
    }
    
    @MainActor
    func presentErrorMessage() {
        if errorMessage != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.errorMessage = nil
            }
        }
    }
    
    func initialize() throws -> EmbeddedWallet {
        guard instance == nil else {
            return instance!
        }
        
        return try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
    }
    
    func getURLForLogFiles() -> URL? {
        if let instance = try? initialize() {
            return instance.getURLForLogFiles()
        }

        return nil
    }
    
    //MARK: - EmbeddedWalletAccountsProtocol -
    
    func createAccount() async throws -> Int? {
        let instance = try initialize()
        return try await instance.createAccount().accountId
    }

    func fetchAllAccounts() async throws -> [Account] {
        let instance = try initialize()
        return try await instance.getAccounts().data ?? []
    }
    
    func fetchAllAccountsWithPagination(pageCursor: String?, pageSize: Int?, order: Order) async throws -> PaginatedResponse<Account>? {
        let instance = try initialize()
        return try await instance.getAccounts(allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
    }
    
    func getLatestBackup() async throws -> LatestBackupResponse {
        let instance = try initialize()
        return try await instance.getLatestBackup()
    }
    
    func getDevice(deviceId: String) async throws -> Device {
        let instance = try initialize()
        return try await instance.getDevice(deviceId: deviceId)
    }

    
    //MARK: - EmbeddedWalletAssetsProtocol -

    func addAsset(assetId: String, accountId: Int) async throws -> EmbeddedWalletSDKDev.AddressDetails {
        let instance = try initialize()
        return try await instance.addAsset(accountId: accountId, assetId: assetId)
    }
    
    func getAsset(assetId: String, accountId: Int) async throws -> EmbeddedWalletSDKDev.Asset {
        let instance = try initialize()
        return try await instance.getAsset(accountId: accountId, assetId: assetId)
    }

    func getAssetBalance(assetId: String, accountId: Int) async throws -> EmbeddedWalletSDKDev.AssetBalance {
        let instance = try initialize()
        return try await instance.getBalance(accountId: accountId, assetId: assetId)
    }

    func refreshAssetBalance(assetId: String, accountId: Int) async throws -> EmbeddedWalletSDKDev.AssetBalance {
        let instance = try initialize()
        return try await instance.refreshBalance(accountId: accountId, assetId: assetId)
    }

    func fetchAllAccountAssets(accountId: Int) async throws -> [EmbeddedWalletSDKDev.Asset] {
        let instance = try initialize()
        return try await instance.getAssets(accountId: accountId).data ?? []
    }
    
    func fetchAccountAssetsWithPagination(accountId: Int, pageCursor: String?, pageSize: Int?, order: Order) async throws -> PaginatedResponse<EmbeddedWalletSDKDev.Asset> {
        let instance = try initialize()
        return try await instance.getAssets(accountId: accountId, allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
    }

    func fetchAllAccountAssetAddresses(assetId: String, accountId: Int) async throws -> [EmbeddedWalletSDKDev.AddressDetails] {
        let instance = try initialize()
        return try await instance.getAddresses(accountId: accountId, assetId: assetId).data ?? []
    }
    
    func fetchAccountAssetAddressesWithPagination(assetId: String, accountId: Int, pageCursor: String?, pageSize: Int?, order: Order) async throws -> PaginatedResponse<EmbeddedWalletSDKDev.AddressDetails> {
        let instance = try initialize()
        return try await instance.getAddresses(accountId: accountId, assetId: assetId, allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
    }

    func fetchAllSupportedAssets() async throws -> [EmbeddedWalletSDKDev.Asset] {
        let instance = try initialize()
        return try await instance.getSupportedAssets(onlyBaseAssets: true).data ?? []
    }
    
    func fetchSupportedAssetsWithPagination(pageCursor: String?, pageSize: Int?, order: Order) async throws -> PaginatedResponse<EmbeddedWalletSDKDev.Asset> {
        let instance = try initialize()
        return try await instance.getSupportedAssets(allPages: true, pageCursor: pageCursor, pageSize: pageSize, onlyBaseAssets: true)
    }
    
    func getTransactions(after: String? = nil, pageCursor: String?, order: Order, incoming: Bool? = nil, sourceId: String? = nil, outgoing: Bool? = nil, destId: String? = nil) async throws -> PaginatedResponse<EmbeddedWalletSDKDev.TransactionResponse> {
        let instance = try initialize()
        return try await instance.getTransactions(after: after, incoming: incoming, outgoing: outgoing, sourceId: sourceId, destId: destId, pageCursor: pageCursor)
    }
    
    func getTransactionById(txId: String) async throws-> EmbeddedWalletSDKDev.TransactionResponse {
        if let mockManager {
            return try await mockManager.getTransactionById(txId: txId)
        }
        let instance = try initialize()
        return try await instance.getTransaction(txId: txId)
    }
    
    func createTypedMessageTransaction(accountId: Int, asset: String) async throws -> EmbeddedWalletSDKDev.CreateTransactionResponse {
        let instance = try initialize()
        let content = try getTypedDataJson()
        let message = UnsignedRawMessage(content: content, type: "EIP712")
        let rawMessageData = RawMessageData(messages: [message])
        let extraParameters = ExtraParameters(rawMessageData: rawMessageData)
        
        return try await instance.createTransaction(transactionRequest: TransactionRequest(operation: .typedMessage, assetId: asset, source: SourceTransferPeerPath(id: "\(accountId)"), extraParameters: extraParameters))
    }
    
    func estimateOneTimeAddressTransaction(accountId: Int, assetId: String, destAddress: String, amount: String, feeLevel: FeeLevel?) async throws -> EstimatedTransactionFeeResponse {
        if let mockManager {
            return try await mockManager.estimateOneTimeAddressTransaction(accountId: accountId, assetId: assetId, destAddress: destAddress, amount: amount, feeLevel: feeLevel)
        }

        let instance = try initialize()
        let request = TransactionRequest(
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .oneTimeAddress, oneTimeAddress: OneTimeAddress(address: destAddress)),
            amount: amount,
            feeLevel: feeLevel
        )
        return try await instance.estimateTransactionFee(transactionRequest: request)
    }

    func createOneTimeAddressTransaction(accountId: Int, assetId: String, destAddress: String, amount: String, feeLevel: FeeLevel?) async throws -> EmbeddedWalletSDKDev.CreateTransactionResponse {
        if let mockManager {
            return try await mockManager.createOneTimeAddressTransaction(accountId: accountId, assetId: assetId, destAddress: destAddress, amount: amount, feeLevel: feeLevel)
        }

        let instance = try initialize()
        let request = TransactionRequest(
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .oneTimeAddress, oneTimeAddress: OneTimeAddress(address: destAddress)),
            amount: amount,
            feeLevel: feeLevel
        )
        return try await instance.createTransaction(transactionRequest: request)
    }
    
    func estimateEndUserWalletTransaction(accountId: Int, assetId: String, destWalletId: String, destinationAccountId: Int, amount: String, feeLevel: FeeLevel) async throws -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse {
        let instance = try initialize()
        let request = TransactionRequest(
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .endUserWallet, id: String(destinationAccountId), walletId: destWalletId),
            amount: amount,
            feeLevel: feeLevel
        )
        return try await instance.estimateTransactionFee(transactionRequest: request)
    }

    func createEndUserWalletTransaction(accountId: Int, assetId: String, destWalletId: String, destinationAccountId: Int, amount: String, feeLevel: FeeLevel?) async throws -> EmbeddedWalletSDKDev.CreateTransactionResponse {
        let instance = try initialize()
        let request = TransactionRequest(
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .endUserWallet, id: String(destinationAccountId), walletId: destWalletId),
            amount: amount,
            feeLevel: feeLevel
        )
        return try await instance.createTransaction(transactionRequest: request)
    }

    func estimateVaultTransaction(accountId: Int, assetId: String, vaultAccountId: String, amount: String, feeLevel: FeeLevel?) async throws -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse {
        let instance = try initialize()
        let request = TransactionRequest(
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .vaultAccount, id: String(vaultAccountId)),
            amount: amount,
            feeLevel: feeLevel
        )
        return try await instance.estimateTransactionFee(transactionRequest: request)
    }

    
    func createVaultTransaction(accountId: Int, assetId: String, vaultAccountId: String, amount: String, feeLevel: FeeLevel?) async throws -> EmbeddedWalletSDKDev.CreateTransactionResponse {
        let instance = try initialize()
        let request = TransactionRequest(
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .vaultAccount, id: String(vaultAccountId)),
            amount: amount,
            feeLevel: feeLevel
        )
        return try await instance.createTransaction(transactionRequest: request)
    }

    func estimateContractCallTransaction(accountId: Int, assetId: String, contractCallData: String, amount: String, feeLevel: FeeLevel) async throws -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse {
        let instance = try initialize()
        let request = TransactionRequest(
            operation: .contractCall,
            note: "Created by iOS unit tests - contract call",
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .oneTimeAddress, oneTimeAddress: OneTimeAddress(address: "0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45")),
            amount: amount,
            extraParameters: ExtraParameters(contractCallData: contractCallData)
        )
        return try await instance.estimateTransactionFee(transactionRequest: request)
    }

    func createContractCallTransaction(accountId: Int, assetId: String, contractCallData: String, amount: String, feeLevel: FeeLevel) async throws -> EmbeddedWalletSDKDev.CreateTransactionResponse {
        let instance = try initialize()
        let request = TransactionRequest(
            operation: .contractCall,
            note: "Created by iOS unit tests - contract call",
            assetId: assetId,
            source: SourceTransferPeerPath(id: String(accountId)),
            destination: DestinationTransferPeerPath(type: .oneTimeAddress, oneTimeAddress: OneTimeAddress(address: "0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45")),
            amount: amount,
            extraParameters: ExtraParameters(contractCallData: contractCallData)
        )
        return try await instance.createTransaction(transactionRequest: request)
    }

    func cancelTransaction(txId: String) async throws -> EmbeddedWalletSDKDev.SuccessResponse {
        let instance = try initialize()
        return try await instance.cancelTransaction(txId: txId)
    }
    
    //MARK: - Web3Connections -
    
    func getConnections(allPages: Bool = true, pageCursor: String? = nil, order: Order? = nil, filter: Web3Filter? = nil, sort: Web3ConnectionSort? = nil, pageSize: Int? = nil) async throws -> PaginatedResponse<Web3Connection> {
        if let mockManager {
            return try await mockManager.getConnections(allPages: allPages, pageCursor: pageCursor, order: order, filter: filter, sort: sort, pageSize: pageSize)
        }
        
        let instance = try initialize()
        let result = try await instance.getWeb3Connections(allPages: allPages, pageCursor: pageCursor, pageSize: pageSize, order: order, filter: filter, sort: sort)
        return result
    }
    
    func createConnection(feeLevel: Web3ConnectionFeeLevel, uri: String, ncwAccountId: Int, chainIds: [String]? = nil) async throws -> CreateWeb3ConnectionResponse {
        if let mockManager {
            return try await mockManager.createConnection(feeLevel: feeLevel, uri: uri, ncwAccountId: ncwAccountId, chainIds: chainIds)
        }

        let instance = try initialize()
        let request = Web3ConnectionRequest(feeLevel: feeLevel, uri: uri, ncwAccountId: ncwAccountId, chainIds: chainIds)
        
        return try await instance.createWeb3Connection(body: request)
    }

    func submitConnection(id: String, approve: Bool) async throws -> String {
        if let mockManager {
            return try await mockManager.submitConnection(id: id, approve: approve)
        }
        
        let instance = try initialize()
        let request = RespondToConnectionRequest(approve: approve)
        return try await instance.submitWeb3Connection(id: id, payload: request)
    }

    func removeConnection(id: String) async throws -> String {
        if let mockManager {
            return try await mockManager.removeConnection(id: id)
        }
        
        let instance = try initialize()
        return try await instance.removeWeb3Connection(id: id)
    }

    //MARK: - NFTs -

    func getNFT(id: String) async throws -> TokenResponse? {
        if let mockManager {
            return try await mockManager.getNFT(id: id)
        }

        let instance = try initialize()
        return try await instance.getNFT(id: id)
    }
    
    func getOwnedNFTs(
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
        if let mockManager {
            return try await mockManager.getOwnedNFTs()
        }

        let instance = try initialize()
        return try await instance.getOwnedNFTs(blockchainDescriptor: blockchainDescriptor, ncwAccountIds: ncwAccountIds, ids: ids, collectionIds: collectionIds, allPages: allPages, pageCursor: pageCursor, pageSize: pageSize, sort: sort, order: order, status: status, search: search, spam: spam)
    }

    func listOwnedCollections(
        allPages: Bool = true,
        pageCursor: String? = nil,
        pageSize: Int? = nil,
        sort: [ListOwnedTokensSort]? = nil,
        order: Order? = nil,
        status: TokensStatus? = nil,
        search: String? = nil
    ) async throws -> PaginatedResponse<TokenOwnershipResponse> {
        let instance = try initialize()
        return try await instance.listOwnedCollections(allPages: allPages, pageCursor: pageCursor, pageSize: pageSize, sort: sort, order: order, status: status, search: search)
    }

    func listOwnedAssets(
        allPages: Bool = true,
        pageCursor: String? = nil,
        pageSize: Int? = nil,
        sort: [ListOwnedTokensSort]? = nil,
        order: Order? = nil,
        status: TokensStatus? = nil,
        search: String? = nil,
        spam: TokensSpam? = nil
    ) async throws -> PaginatedResponse<TokenOwnershipResponse> {
        let instance = try initialize()
        return try await instance.listOwnedAssets(allPages: allPages, pageCursor: pageCursor, pageSize: pageSize, sort: sort, order: order, status: status, search: search, spam: spam)
    }


}

//MARK - AuthTokenRetriever -
extension EWManager: AuthTokenRetriever {
    func getAuthToken() async -> Result<String, any Error> {
        if let token = await AuthRepository.getUserIdToken() {
            return .success(token)
        } else {
            return .failure(CustomError.genericError("Failed to get user token"))
        }
    }
}

//MARK - Core -
extension EWManager {
    func initializeCore() throws -> Fireblocks {
        let deviceId = FireblocksManager.shared.deviceId
        self.keyStorageDelegate = KeyStorageProvider(deviceId: deviceId)
        if let keyStorageDelegate {
            let instance = try initialize()
            return try instance.initializeCore(deviceId: deviceId, keyStorage: keyStorageDelegate)
        }
        
        throw NSError()

    }
    
    func getCore() throws -> Fireblocks {
        let deviceId = FireblocksManager.shared.deviceId
        return try Fireblocks.getInstance(deviceId: deviceId)
    }

    func generateKeys(algorithms: Set<Algorithm>) async throws -> Set<KeyDescriptor> {
        let instance = try getCore()
        return try await instance.generateMPCKeys(algorithms: algorithms)
    }
    
    func backupKeys() async throws -> Set<KeyBackup> {
        let instance = try getCore()
        return try await instance.backupKeys(passphrase: "passphrase", passphraseId: "62EB34DA-444A-4103-A0FD-80496F2D707C")
    }

}

extension EWManager {
    struct TypedData: Codable {
        let types: Types
        let primaryType: String
        let domain: Domain
        let message: MessageContent
    }

    struct Types: Codable {
        let EIP712Domain: [TypeField]
        let Permit: [TypeField]
    }

    struct TypeField: Codable {
        let name: String
        let type: String
    }

    struct Domain: Codable {
        let name: String
        let version: String
        let chainId: Int
        let verifyingContract: String
    }

    struct MessageContent: Codable {
        let holder: String
        let spender: String
        let nonce: Int
        let expiry: Int
        let allowed: Bool
    }

    func getTypedDataJson() throws -> String {
        let typedData = buildTypedData()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]
        let data = try encoder.encode(typedData)
        return String(data: data, encoding: .utf8) ?? ""
    }

    func buildTypedData(chainId: Int = 42,
                        fromAddress: String = "0x9EE5e175D09895b8E1E28c22b961345e1dF4B5aE",
                        spender: String = "0xE1B48CddD97Fa4b2F960Ca52A66CeF8f1f8A58A5",
                        nonce: Int = 1) -> TypedData {
        
        return TypedData(
            types: Types(
                EIP712Domain: [
                    TypeField(name: "name", type: "string"),
                    TypeField(name: "version", type: "string"),
                    TypeField(name: "chainId", type: "uint256"),
                    TypeField(name: "verifyingContract", type: "address")
                ],
                Permit: [
                    TypeField(name: "holder", type: "address"),
                    TypeField(name: "spender", type: "address"),
                    TypeField(name: "nonce", type: "uint256"),
                    TypeField(name: "expiry", type: "uint256"),
                    TypeField(name: "allowed", type: "bool")
                ]
            ),
            primaryType: "Permit",
            domain: Domain(
                name: "Dai Stablecoin",
                version: "1",
                chainId: chainId,
                verifyingContract: "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"
            ),
            message: MessageContent(
                holder: fromAddress,
                spender: spender,
                nonce: nonce,
                expiry: Int(Date().timeIntervalSince1970) + 60,
                allowed: true
            )
        )
    }
}
