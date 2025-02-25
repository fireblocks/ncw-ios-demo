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
class EWManagerMock {
    func getConnections(allPages: Bool = true, pageCursor: String? = nil, order: Order? = nil, filter: String? = nil, sort: Web3ConnectionSort? = nil, pageSize: Int? = nil) async -> PaginatedResponse<Web3Connection>? {

        if let data = Mocks.Connections.getResponse.data(using: .utf8) {
            if let asset: PaginatedResponse<Web3Connection> = try? GenericDecoder.decode(data: data) {
                return asset
            }
        }
        return nil
    }
    
    func createConnection(feeLevel: Web3ConnectionFeeLevel, uri: String, ncwAccountId: Int, chainIds: [String]? = nil) async -> CreateWeb3ConnectionResponse? {
        if let data = Mocks.Connections.create.data(using: .utf8) {
            if let asset: CreateWeb3ConnectionResponse = try? GenericDecoder.decode(data: data) {
                return asset
            }
        }
        
        return nil
    }
    
    func submitConnection(id: String, approve: Bool) async -> String? {
        return "true"
    }

    func removeConnection(id: String) async -> String? {
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
        if let data = Mocks.Asset.response.data(using: .utf8) {
            if let asset: Asset = try? GenericDecoder.decode(data: data) {
                return [asset]
            }
        }
        return []
    }
    
    override func getTransactionById(txId: String) async -> TransactionResponse? {
        return Mocks.Transaction.getResponse()
    }
    
    override func fetchAllSupportedAssets() async -> [Asset] {
        if let data = Mocks.Asset.response.data(using: .utf8) {
            if let asset: Asset = try? GenericDecoder.decode(data: data) {
                return [asset]
            }
        }
        return []
    }
    
    override func getAssetBalance(assetId: String, accountId: Int) async -> AssetBalance? {
        if let data = Mocks.GetAssetBalance.response.data(using: .utf8) {
            if let asset: AssetBalance = try? GenericDecoder.decode(data: data) {
                return asset
            }
        }
        return nil
    }
    
    override func fetchAllAccountAssetAddresses(assetId: String, accountId: Int) async -> [AddressDetails] {
        if let data = Mocks.GetAssetAddresses.response.data(using: .utf8) {
            if let asset: PaginatedResponse<AddressDetails> = try? GenericDecoder.decode(data: data) {
                return asset.data ?? []
            }
        }
        return []
    }
    
    override func getConnections(allPages: Bool = true, pageCursor: String? = nil, order: Order? = nil, filter: String? = nil, sort: Web3ConnectionSort? = nil, pageSize: Int? = nil) async -> PaginatedResponse<Web3Connection>? {

        if let data = Mocks.Connections.getResponse.data(using: .utf8) {
            if let asset: PaginatedResponse<Web3Connection> = try? GenericDecoder.decode(data: data) {
                return asset
            }
        }
        return nil
    }
    
    override func removeConnection(id: String) async -> String? {
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

struct Mocks {
    struct Account {
        static let response = """
        [{\"accountId\":0,\"walletId\":\"\(Constants.walletId)\"},
        {\"accountId\":1,\"walletId\":\"\(Constants.walletId)\"}]
        """

    }
    
    struct Asset {
        static func getAsset() -> EmbeddedWalletSDKDev.Asset {
            let data = Mocks.Asset.response.data(using: .utf8)
            let response: EmbeddedWalletSDKDev.Asset = try! GenericDecoder.decode(data: data!)!
            return response
        }
        
        static let response = """
        {
          "id": "string",
          "symbol": "\(Constants.ETH_TEST5)",
          "name": "\(Constants.ETH_TEST5)",
          "decimals": 0,
          "networkProtocol": "string",
          "testnet": true,
          "hasFee": true,
          "type": "string",
          "baseAsset": "string",
          "ethNetwork": "0",
          "ethContractAddress": "string",
          "issuerAddress": "string",
          "blockchainSymbol": "string",
          "deprecated": true,
          "coinType": 0,
          "blockchain": "string",
          "blockchainDisplayName": "string",
          "algorithm": "MPC_ECDSA_SECP256K1"
        }
        """
    }
    
    struct GetAssetBalance {
        static let response = """
        {
          "id": "\(Constants.ETH_TEST5)",
          "total": "100",
          "available": "string",
          "pending": "string",
          "frozen": "string",
          "lockedAmount": "string",
          "blockHeight": "string",
          "blockHash": "string",
          "rewardInfo": {
            "pendingRewards": "string"
          }
        }
        
        """
    }
    
    struct GetAssetAddresses {
        static let response = """
        {\"data\":
        [
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "address": "string",
          "asset": "\(Constants.ETH_TEST5)",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        },
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "asset": "\(Constants.BTC_TEST)",
          "address": "string",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        }
        ]}
        """
        
        static let responseAllMissingMandatory = """
        {\"data\":
        [
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "address": "string",
          "asset": "\(Constants.ETH_TEST5)",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        },
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "address": "string",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        }
        ]}
        """
        
        static let pagingFirst = """
        {\"data\":
        [
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "asset": "\(Constants.ETH_TEST5)",
          "address": "string",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        }
        ],
        \"paging\":{\"next\":\"MA==1\"}}
        """
        
        static let pagingSecond = """
        {\"data\":
        [
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "asset": "\(Constants.BTC_TEST)",
          "address": "string",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        }
        ],
        \"paging\":{\"next\":\"MA==2\"}}
        """
        
        static let pagingSecondMissingMandatory = """
        {\"data\":
        [
        {
          "accountName": "string",
          "asset": "\(Constants.BTC_TEST)",
          "address": "string",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        }
        ],
        \"paging\":{\"next\":\"MA==2\"}}
        """
        
        static let pagingLast = """
        {\"data\":
        [
        {
          "accountName": "string",
          "accountId": "\(Constants.accountId)",
          "asset": "\(Constants.SOL_TEST)",
          "address": "string",
          "addressType": "string",
          "addressDescription": "string",
          "tag": "string",
          "addressIndex": 0,
          "change": 0,
          "coinType": 0,
          "customerRefId": "string",
          "addressFormat": "string",
          "legacyAddress": "string",
          "paymentAddress": "string",
          "userDefined": true,
          "state": "PENDING_ACTIVATION"
        }
        ]}
        """
    }

    
    struct Transaction {
        static let estimatedFee = #"""
            {"low":{"networkFee":"0.000012"},"medium":{"networkFee":"0.000015"},"high":{"networkFee":"0.000024"}}
            """#
        static func getFee() -> EstimatedTransactionFeeResponse? {
            if let data = Mocks.Transaction.estimatedFee.data(using: .utf8) {
                let response: EstimatedTransactionFeeResponse? = try? GenericDecoder.decode(data: data)
                return response
            }
            return nil

        }
        
        static func getResponse() -> TransactionResponse {
            let data = Mocks.Transaction.response.data(using: .utf8)
            let response: TransactionResponse = try! GenericDecoder.decode(data: data!)!
            return response
        }
        
        static let response = #"""
        {"id":"faa40b60-e950-460d-a6d2-ca2611a87e44","createdAt":1735128255934,"lastUpdated":1735128259368,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"PENDING_SIGNATURE","txHash":"","subStatus":"","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"}
        """#
        struct Get {
            static let missingDirection = #"{"errorCode":"UNKNOWN","errorMessage":"incoming or outgoing must be specified"}"#
            static let responseIncoming = #"""
                [{"id":"c78dec41-dd46-4f9d-885c-4668fa127afb","createdAt":1734531624870,"lastUpdated":1734531625152,"assetId":"XRP_TEST","source":{"id":"","type":"UNKNOWN","name":"External","subType":""},"destination":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"amount":10,"fee":0.000012,"networkFee":0.000012,"netAmount":10,"sourceAddress":"rifZYuhM3WxHzFYY8PMWgGEDnznR3M7bL","destinationAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddressDescription":"","destinationTag":"","status":"COMPLETED","txHash":"A571B08F72FE7F746795A934B834A8B73BC80345E1CC76609A2286E122DB41F2","subStatus":"CONFIRMED","signedBy":[],"createdBy":"","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":10,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"10","requestedAmount":"10","netAmount":"10"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3225594"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"0c20492e-ed67-46fa-b60e-11d542eb21b5","createdAt":1734528120087,"lastUpdated":1734528120406,"assetId":"XRP_TEST","source":{"id":"","type":"UNKNOWN","name":"External","subType":""},"destination":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"amount":10,"fee":0.000012,"networkFee":0.000012,"netAmount":10,"sourceAddress":"rifZYuhM3WxHzFYY8PMWgGEDnznR3M7bL","destinationAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddressDescription":"","destinationTag":"","status":"COMPLETED","txHash":"1E04D925B838504C220610C5DF098CD215B94168535C794BB739575BDDAAA2E3","subStatus":"CONFIRMED","signedBy":[],"createdBy":"","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":10,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"10","requestedAmount":"10","netAmount":"10"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3224449"},"signedMessages":[],"assetType":"BASE_ASSET"}]
                """#
            
            static let responseOutgoing = #"""
            [{"id":"92e310fd-8260-47ff-b8a9-d8fef7deca93","createdAt":1734946447745,"lastUpdated":1734946503435,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"type":"ONE_TIME_ADDRESS","name":"N/A","subType":""},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"rgbGn2c8mxiJWJW6yEb3xybwRiCQHSFEU","destinationAddressDescription":"","destinationTag":"","status":"COMPLETED","txHash":"BC35DFC19C052F7326A6C655DC7426627E9773A967A00B8630D392450FAE5C4B","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3360465"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"70475014-ff48-44fe-9caf-b7dff489fc2f","createdAt":1734945339508,"lastUpdated":1734945400982,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"rGSkAhb49jhUXqBVVd2rD7wELqrQY8fjzk","destinationAddressDescription":"","destinationTag":"819206700","status":"COMPLETED","txHash":"6C9BD0FC08B5D16996B766AE658D2E621CBAE0009062EA36E8DCF550F0A4A436","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3360104"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"8f90927c-30d1-4823-bf1f-936245c3aad6","createdAt":1734593210490,"lastUpdated":1734593228573,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"CANCELLED","txHash":"","subStatus":"CANCELLED_BY_USER","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"22feeb23-0b39-4190-88e2-3752d4454b18","createdAt":1734535619614,"lastUpdated":1734535630242,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"type":"UNKNOWN","name":"N/A","subType":""},"amount":null,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"CANCELLED","txHash":"","subStatus":"CANCELLED_BY_USER","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":null,"feeCurrency":"XRP_TEST","operation":"TYPED_MESSAGE","amountInfo":{},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"extraParameters":{"rawMessageData":{"messages":[{"type":"EIP712","index":0,"content":{"types":{"Permit":[{"name":"holder","type":"address"},{"name":"spender","type":"address"},{"name":"nonce","type":"uint256"},{"name":"expiry","type":"uint256"},{"name":"allowed","type":"bool"}],"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}]},"domain":{"name":"Dai Stablecoin","chainId":42,"version":"1","verifyingContract":"0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"},"message":{"nonce":1,"expiry":1734535679,"holder":"0x9EE5e175D09895b8E1E28c22b961345e1dF4B5aE","allowed":1,"spender":"0xE1B48CddD97Fa4b2F960Ca52A66CeF8f1f8A58A5"},"primaryType":"Permit"}}]}},"assetType":"BASE_ASSET"},{"id":"1def2550-35da-46a7-afe7-d2909f25588a","createdAt":1734534874429,"lastUpdated":1734534909953,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"type":"ONE_TIME_ADDRESS","name":"N/A","subType":""},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"r4Qf5ygZAzvb7oGXBSwGegam7XXVduntn2","destinationAddressDescription":"","destinationTag":"","status":"COMPLETED","txHash":"8CCE86855D91BFD02C697EAE600434DFC7CE018C7399AE9DE30FB15B08FFC1EC","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3226648"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"41c2eef4-bebe-4b82-8e7b-038693b32cae","createdAt":1734534781638,"lastUpdated":1734534815572,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"9539fbb1-55f5-bf5d-8fc4-215f5be43a19"},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"r4Qf5ygZAzvb7oGXBSwGegam7XXVduntn2","destinationAddressDescription":"","destinationTag":"359273911","status":"COMPLETED","txHash":"F99AACDA1EE60D926FF596DC96011641243C1A999709564EF24B3B7AA79E75AA","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3226618"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"228972e0-5f68-4d22-82b8-a18130e39f1a","createdAt":1734533898457,"lastUpdated":1734533941604,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"rGSkAhb49jhUXqBVVd2rD7wELqrQY8fjzk","destinationAddressDescription":"","destinationTag":"819206700","status":"COMPLETED","txHash":"E79DBC855C913AF40543BE6C3CE78F2F0CE151FAC661EC3A18F7F0659E48BCE7","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3226335"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"c8c52cd6-e1a9-4a15-b31a-f16194cd3f64","createdAt":1734532708353,"lastUpdated":1734532738279,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"rGSkAhb49jhUXqBVVd2rD7wELqrQY8fjzk","destinationAddressDescription":"","destinationTag":"819206700","status":"COMPLETED","txHash":"F87495C862FBCF92A057A32A1293E17DA8C71B8D41356609292777CAD999ADDC","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3225954"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"239baf7a-9f2f-476d-af65-2ca59ea1f5a3","createdAt":1734532455187,"lastUpdated":1734532499909,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":0.000012,"networkFee":0.000012,"netAmount":1,"sourceAddress":"rhG4YWtBe8s9v72Q3MtjDrUL9kkZcYPgUK","destinationAddress":"rGSkAhb49jhUXqBVVd2rD7wELqrQY8fjzk","destinationAddressDescription":"","destinationTag":"819206700","status":"COMPLETED","txHash":"8E1644280D5A610B38C1F0817FFF81455B9217990193E84DE879F99074A521FD","subStatus":"CONFIRMED","signedBy":["43306d09-0250-4287-b928-1ef38c9e12ec"],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":100,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","numOfConfirmations":1,"amountInfo":{"amount":"1","requestedAmount":"1","netAmount":"1","amountUSD":"100"},"feeInfo":{"networkFee":"0.000012"},"destinations":[],"blockInfo":{"blockHeight":"3225880"},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"75a8a5e8-add4-4d38-8082-c33887972b06","createdAt":1734531552457,"lastUpdated":1734531560952,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"FAILED","txHash":"","subStatus":"INSUFFICIENT_RESERVED_FUNDING","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"45327b6f-56c2-4172-961c-fb7ba33721b4","createdAt":1734531452908,"lastUpdated":1734531457152,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"VAULT_ACCOUNT","name":"Default","subType":""},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"FAILED","txHash":"","subStatus":"INSUFFICIENT_RESERVED_FUNDING","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"aae4e960-e13f-4867-b2ee-f9d4b031aa7e","createdAt":1734531362828,"lastUpdated":1734531366464,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"9539fbb1-55f5-bf5d-8fc4-215f5be43a19"},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"FAILED","txHash":"","subStatus":"INSUFFICIENT_RESERVED_FUNDING","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"aa166404-0174-4d65-a090-56f94483cfb3","createdAt":1734531245826,"lastUpdated":1734531255484,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"type":"ONE_TIME_ADDRESS","name":"N/A","subType":""},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"rgbGn2c8mxiJWJW6yEb3xybwRiCQHSFEU","destinationAddressDescription":"","destinationTag":"","status":"FAILED","txHash":"","subStatus":"INSUFFICIENT_RESERVED_FUNDING","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"a6bbdea4-896a-4787-9e91-6b5c445453d3","createdAt":1734528245023,"lastUpdated":1734528252723,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"9539fbb1-55f5-bf5d-8fc4-215f5be43a19"},"amount":1,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"FAILED","txHash":"","subStatus":"INSUFFICIENT_RESERVED_FUNDING","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":1,"feeCurrency":"XRP_TEST","operation":"TRANSFER","amountInfo":{"amount":"1","requestedAmount":"1"},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[],"assetType":"BASE_ASSET"},{"id":"ee406e65-d1df-49ca-a256-5f444109c764","createdAt":1734528173855,"lastUpdated":1734528213037,"assetId":"XRP_TEST","source":{"id":"0","type":"END_USER_WALLET","name":"","subType":"","walletId":"483fafe8-1ce4-4899-050d-44d746a1d7b4"},"destination":{"type":"UNKNOWN","name":"N/A","subType":""},"amount":null,"fee":-1,"networkFee":-1,"netAmount":-1,"sourceAddress":"","destinationAddress":"","destinationAddressDescription":"","destinationTag":"","status":"COMPLETED","txHash":"","subStatus":"","signedBy":[],"createdBy":"43306d09-0250-4287-b928-1ef38c9e12ec","rejectedBy":"","amountUSD":null,"addressType":"","note":"","exchangeTxId":"","requestedAmount":null,"feeCurrency":"XRP_TEST","operation":"TYPED_MESSAGE","amountInfo":{},"feeInfo":{},"destinations":[],"blockInfo":{},"signedMessages":[{"derivationPath":[44,1,0,0,0],"algorithm":"MPC_ECDSA_SECP256K1","publicKey":"023364c14e6cdcbf1de983cf54920af20e222163e5284b84cc1a48d183b790f900","signature":{"fullSig":"40185fa2f1e0a96c39e8f83d7007a3e3d02965c92bbbff604cd7f9ba3fdbb2a76ef5285dc95937d499fc68035bda5932675dfb965f3de408fc18f815c2111350","r":"40185fa2f1e0a96c39e8f83d7007a3e3d02965c92bbbff604cd7f9ba3fdbb2a7","s":"6ef5285dc95937d499fc68035bda5932675dfb965f3de408fc18f815c2111350","v":0},"content":"d85bee6e2eb0bdb29f3f414554bb42a3d8874e3bc955ff9d5247296e84708265"}],"extraParameters":{"rawMessageData":{"messages":[{"type":"EIP712","index":0,"content":{"types":{"Permit":[{"name":"holder","type":"address"},{"name":"spender","type":"address"},{"name":"nonce","type":"uint256"},{"name":"expiry","type":"uint256"},{"name":"allowed","type":"bool"}],"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}]},"domain":{"name":"Dai Stablecoin","chainId":42,"version":"1","verifyingContract":"0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa"},"message":{"nonce":1,"expiry":1734528233,"holder":"0x9EE5e175D09895b8E1E28c22b961345e1dF4B5aE","allowed":1,"spender":"0xE1B48CddD97Fa4b2F960Ca52A66CeF8f1f8A58A5"},"primaryType":"Permit"}}]}},"assetType":"BASE_ASSET"}]
            """#
        }

    }
    
    struct Connections {
        static let connection = #"""
            {"id":"f05314fc02e98b846072d9381dd8a8e4e237999155971e088649281bc957c697","userId":"e414094b-07dc-4eb9-9873-7e723c8dda86","sessionMetadata":{"appUrl":"https://react-app.walletconnect.com","appName":"React App","appDescription":"App to test WalletConnect network","appIcon":"https://react-app.walletconnect.com/assets/eip155-1.png"},"feeLevel":"MEDIUM","ncwId":"280b3ca9-0b5d-81b9-ae17-c2c096f79608","ncwAccountId":0,"chainIds":[],"connectionType":"WalletConnect","connectionMethod":"API","creationDate":"2025-02-23T14:30:57.151Z"}
        """#
        
        static let getResponse = #"""
        {"data":[{"id":"f05314fc02e98b846072d9381dd8a8e4e237999155971e088649281bc957c697","userId":"e414094b-07dc-4eb9-9873-7e723c8dda86","sessionMetadata":{"appUrl":"https://react-app.walletconnect.com","appName":"React App","appDescription":"App to test WalletConnect network","appIcon":"https://react-app.walletconnect.com/assets/eip155-1.png"},"feeLevel":"MEDIUM","ncwId":"280b3ca9-0b5d-81b9-ae17-c2c096f79608","ncwAccountId":0,"chainIds":[],"connectionType":"WalletConnect","connectionMethod":"API","creationDate":"2025-02-23T14:30:57.151Z"}, {"id":"f05314fc02e98b846072d9381dd8a8e4e237999155971e088649281bc957c697","userId":"e414094b-07dc-4eb9-9873-7e723c8dda86","sessionMetadata":{"appUrl":"https://react-app.walletconnect.com","appName":"React App","appDescription":"App to test WalletConnect network"},"feeLevel":"MEDIUM","ncwId":"280b3ca9-0b5d-81b9-ae17-c2c096f79608","ncwAccountId":0,"chainIds":[],"connectionType":"WalletConnect","connectionMethod":"API","creationDate":"2025-02-23T14:30:57.151Z"}, {"id":"f05314fc02e98b846072d9381dd8a8e4e237999155971e088649281bc957c697","userId":"e414094b-07dc-4eb9-9873-7e723c8dda86","sessionMetadata":{"appUrl":"https://react-app.walletconnect.com","appName":"React App","appDescription":"App to test WalletConnect network","appIcon":"https://react-app.walletconnect.com/assets/eip155-1.png"},"feeLevel":"MEDIUM","ncwId":"280b3ca9-0b5d-81b9-ae17-c2c096f79608","ncwAccountId":0,"chainIds":[],"connectionType":"WalletConnect","connectionMethod":"API","creationDate":"2025-02-23T14:30:57.151Z"}]}
    """#
        
        static let create = #"""
        {"id":"76363abdcd8f3aab934d8d4ebe071c7342a11f359469732b34866653ca8049e6","sessionMetadata":{"appUrl":"https://react-app.walletconnect.com","appName":"React App","appDescription":"App to test WalletConnect network","appId":"1b7cc750f7c211f322425db166e386de4468cab5127d0a5a9c21ef3a637af853"},"urlScanResult":null}
        """#
        
    }
    
}


