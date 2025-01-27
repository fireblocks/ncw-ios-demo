//
//  EWManager.swift
//  EWDemoPOC
//
//  Created by Dudi Shani-Gabay on 22/09/2024.
//

import Foundation
import EmbeddedWalletSDKDev
import FireblocksDev

@Observable
class EWManager: Hashable {
    static func == (lhs: EWManager, rhs: EWManager) -> Bool {
        return lhs.authClientId == rhs.authClientId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(authClientId)
    }

    static let shared = EWManager()
    private init(){}
    
    let authClientId = "1fcfe7cf-60b4-4111-b844-af607455ff76"
    let options = EmbeddedWalletOptions(env: .DEV9, logLevel: .info, logToConsole: true, logNetwork: true, eventHandlerDelegate: nil, reporting: .init(enabled: true))
    var keyStorageDelegate: KeyStorageProvider?
    var walletId: String?
    var deviceId: String?

    var errorMessage: String? {
        didSet {
            if errorMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.errorMessage = nil
                }
            }
        }
    }
    
    func initialize() -> EmbeddedWallet? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return instance
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func getURLForLogFiles() -> URL? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return instance.getURLForLogFiles()
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    //MARK: - EmbeddedWalletAccountsProtocol -
    func assignWallet() async -> String? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let result = try await instance.assignWallet()
            walletId = result.walletId
            return walletId
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
        
    }
    
    func createAccount() async -> Int? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.createAccount().accountId
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
        
    }

    func fetchAllAccounts() async -> [Account] {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAccounts().data ?? []
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return []
    }
    
    func fetchAllAccountsWithPagination(pageCursor: String?, pageSize: String?, order: Order) async -> PaginatedResponse<Account>? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAccounts(allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func getLatestBackup() async -> LatestBackupResponse? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getLatestBackup()
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    //MARK: - EmbeddedWalletAssetsProtocol -

    func addAsset(assetId: String, accountId: Int) async -> EmbeddedWalletSDKDev.AddressDetails? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.addAsset(accountId: accountId, assetId: assetId)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func getAsset(assetId: String, accountId: Int) async -> EmbeddedWalletSDKDev.Asset? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAsset(accountId: accountId, assetId: assetId)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func getAssetBalance(assetId: String, accountId: Int) async -> EmbeddedWalletSDKDev.AssetBalance? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getBalance(accountId: accountId, assetId: assetId)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func fetchAllAccountAssets(accountId: Int) async -> [EmbeddedWalletSDKDev.Asset] {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAssets(accountId: accountId).data ?? []
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return []
    }
    
    func fetchAccountAssetsWithPagination(accountId: Int, pageCursor: String?, pageSize: String?, order: Order) async -> PaginatedResponse<EmbeddedWalletSDKDev.Asset>? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAssets(accountId: accountId, allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func fetchAllAccountAssetAddresses(assetId: String, accountId: Int) async -> [EmbeddedWalletSDKDev.AddressDetails] {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAddresses(accountId: accountId, assetId: assetId).data ?? []
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return []
    }
    
    func fetchAccountAssetAddressesWithPagination(assetId: String, accountId: Int, pageCursor: String?, pageSize: String?, order: Order) async -> PaginatedResponse<EmbeddedWalletSDKDev.AddressDetails>? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getAddresses(accountId: accountId, assetId: assetId, allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func fetchAllSupportedAssets() async -> [EmbeddedWalletSDKDev.Asset] {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getSupportedAssets().data ?? []
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return []
    }
    
    func fetchSupportedAssetsWithPagination(pageCursor: String?, pageSize: String?, order: Order) async -> PaginatedResponse<EmbeddedWalletSDKDev.Asset>? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getSupportedAssets(allPages: false, pageCursor: pageCursor, pageSize: pageSize, order: order)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func getTransactions(after: String? = nil, pageCursor: String?, order: Order, incoming: Bool? = nil, sourceId: String? = nil, outgoing: Bool? = nil, destId: String? = nil) async -> PaginatedResponse<EmbeddedWalletSDKDev.TransactionResponse>? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getTransactions(after: after, incoming: incoming, outgoing: outgoing, sourceId: sourceId, destId: destId, pageCursor: pageCursor)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func getTransactionById(txId: String) async -> EmbeddedWalletSDKDev.TransactionResponse? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            return try await instance.getTransaction(txId: txId)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func createTypedMessageTransaction(accountId: Int, asset: String) async -> EmbeddedWalletSDKDev.CreateTransactionResponse? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            
            guard let content = getTypedDataJson() else { return nil }
            let message = UnsignedRawMessage(content: content, type: "EIP712")
            let rawMessageData = RawMessageData(messages: [message])
            let extraParameters = ExtraParameters(rawMessageData: rawMessageData)

            return try await instance.createTransaction(transactionRequest: TransactionRequest(operation: .typedMessage, assetId: asset, source: SourceTransferPeerPath(id: "\(accountId)"), extraParameters: extraParameters))
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func estimateOneTimeAddressTransaction(accountId: Int, assetId: String, destAddress: String, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let request = TransactionRequest(
                assetId: assetId,
                source: SourceTransferPeerPath(id: String(accountId)),
                destination: DestinationTransferPeerPath(type: .oneTimeAddress, oneTimeAddress: OneTimeAddress(address: destAddress)),
                amount: amount,
                feeLevel: feeLevel
            )
            return try await instance.estimateTransactionFee(transactionRequest: request)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func createOneTimeAddressTransaction(accountId: Int, assetId: String, destAddress: String, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.CreateTransactionResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let request = TransactionRequest(
                assetId: assetId,
                source: SourceTransferPeerPath(id: String(accountId)),
                destination: DestinationTransferPeerPath(type: .oneTimeAddress, oneTimeAddress: OneTimeAddress(address: destAddress)),
                amount: amount,
                feeLevel: feeLevel
            )
            return try await instance.createTransaction(transactionRequest: request)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }
    
    func estimateEndUserWalletTransaction(accountId: Int, assetId: String, destWalletId: String, destinationAccountId: Int, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let request = TransactionRequest(
                assetId: assetId,
                source: SourceTransferPeerPath(id: String(accountId)),
                destination: DestinationTransferPeerPath(type: .endUserWallet, id: String(destinationAccountId), walletId: destWalletId),
                amount: amount,
                feeLevel: feeLevel
            )
            return try await instance.estimateTransactionFee(transactionRequest: request)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func createEndUserWalletTransaction(accountId: Int, assetId: String, destWalletId: String, destinationAccountId: Int, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.CreateTransactionResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let request = TransactionRequest(
                assetId: assetId,
                source: SourceTransferPeerPath(id: String(accountId)),
                destination: DestinationTransferPeerPath(type: .endUserWallet, id: String(destinationAccountId), walletId: destWalletId),
                amount: amount,
                feeLevel: feeLevel
            )
            return try await instance.createTransaction(transactionRequest: request)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func estimateVaultTransaction(accountId: Int, assetId: String, vaultAccountId: String, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let request = TransactionRequest(
                assetId: assetId,
                source: SourceTransferPeerPath(id: String(accountId)),
                destination: DestinationTransferPeerPath(type: .vaultAccount, id: String(vaultAccountId)),
                amount: amount,
                feeLevel: feeLevel
            )
            return try await instance.estimateTransactionFee(transactionRequest: request)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    
    func createVaultTransaction(accountId: Int, assetId: String, vaultAccountId: String, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.CreateTransactionResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            let request = TransactionRequest(
                assetId: assetId,
                source: SourceTransferPeerPath(id: String(accountId)),
                destination: DestinationTransferPeerPath(type: .vaultAccount, id: String(vaultAccountId)),
                amount: amount,
                feeLevel: feeLevel
            )
            return try await instance.createTransaction(transactionRequest: request)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func estimateContractCallTransaction(accountId: Int, assetId: String, contractCallData: String, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.EstimatedTransactionFeeResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
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
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
    }

    func createContractCallTransaction(accountId: Int, assetId: String, contractCallData: String, amount: String, feeLevel: FeeLevel) async -> EmbeddedWalletSDKDev.CreateTransactionResponse? {
        do {
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
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
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil

    }

    func cancelTransaction(txId: String) async -> EmbeddedWalletSDKDev.SuccessResponse? {
        do {
            errorMessage = nil
            let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
            
            return try await instance.cancelTransaction(txId: txId)
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
            
        return nil
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
    func initializeCore() -> Fireblocks? {
        guard let deviceId else {
            errorMessage = "Unknown Device Id"
            return nil
        }
        self.keyStorageDelegate = KeyStorageProvider(deviceId: deviceId)
        if let keyStorageDelegate {
            do {
                let instance = try EmbeddedWallet(authClientId: authClientId, authTokenRetriever: self, options: options)
                return try instance.initializeCore(deviceId: deviceId, keyStorage: keyStorageDelegate)
            } catch let error as EmbeddedWalletException {
                errorMessage = error.description
            } catch {
                errorMessage = error.localizedDescription
            }
        }
            
        return nil

    }
    
    func getCore() -> Fireblocks? {
        guard let deviceId else {
            errorMessage = "Unknown Device Id"
            return nil
        }

        do {
            return try Fireblocks.getInstance(deviceId: deviceId)
        } catch let error as FireblocksError {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }

        return nil
    }

    func generateKeys(algorithms: Set<Algorithm>) async -> Set<KeyDescriptor>? {
        guard let instance = getCore() else {
            return nil
        }

        do {
            let keys = try await instance.generateMPCKeys(algorithms: algorithms)
            return keys
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
        
        return nil
    }
    
    func backupKeys() async -> Set<KeyBackup>? {
        guard let instance = getCore() else {
            return nil
        }

        do {
            let backupKeys = try await instance.backupKeys(passphrase: "passphrase", passphraseId: "62EB34DA-444A-4103-A0FD-80496F2D707C")
            return backupKeys
        } catch let error as EmbeddedWalletException {
            errorMessage = error.description
        } catch {
            errorMessage = error.localizedDescription
        }
        
        return nil
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

    func getTypedDataJson() -> String? {
        let typedData = buildTypedData()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]
        do {
            let data = try encoder.encode(typedData)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error encoding TypedData: \(error)")
            return nil
        }
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
