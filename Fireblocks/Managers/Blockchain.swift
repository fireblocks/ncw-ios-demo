//
//  Blockchains.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 02/04/2025.
//

struct Blockchain: Codable {
    let descriptor: String
    let displayName: String
    let blockchainProtocolId: String
    let nativeAsset: String
}

struct BlockchainDataContainer {
    static let blockchains = """
[
  {
    "descriptor": "DSETH_DEV",
    "displayName": "dSETH (Dev)",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "DSETH_DEV"
  },
  {
    "descriptor": "BOB_CHAIN_TEST",
    "displayName": "Bob Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "BOB_CHAIN_TEST"
  },
  {
    "descriptor": "PHILCAP_TEST",
    "displayName": "Phillip Capital Network (Testnet)",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "PHILCAP_TEST"
  },
  {
    "descriptor": "ECS",
    "displayName": "eCredits",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ECS"
  },
  {
    "descriptor": "ADA_TEST",
    "displayName": "Cardano Testnet",
    "blockchainProtocolId": "ADA",
    "nativeAsset": "ADA_TEST"
  },
  {
    "descriptor": "ARB_ETH_TEST2",
    "displayName": "Arbitrum Testnet Kovan",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ARB_ETH_TEST2"
  },
  {
    "descriptor": "ADA",
    "displayName": "Cardano",
    "blockchainProtocolId": "ADA",
    "nativeAsset": "ADA"
  },
  {
    "descriptor": "TELOS",
    "displayName": "Telos EVM",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "TELOS"
  },
  {
    "descriptor": "OSMO",
    "displayName": "Osmosis",
    "blockchainProtocolId": "COSMOS",
    "nativeAsset": "OSMO"
  },
  {
    "descriptor": "BLINC_JPY",
    "displayName": "BLINC by BCB Group",
    "blockchainProtocolId": "BANK",
    "nativeAsset": "BLINC_JPY"
  },
  {
    "descriptor": "DOGE_TEST",
    "displayName": "Dogecoin Testnet",
    "blockchainProtocolId": "BTC",
    "nativeAsset": "DOGE_TEST"
  },
  {
    "descriptor": "ALEPH_ZERO_EVM",
    "displayName": "Aleph Zero EVM",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ALEPH_ZERO_EVM"
  },
  {
    "descriptor": "BTC",
    "displayName": "Bitcoin",
    "blockchainProtocolId": "BTC",
    "nativeAsset": "BTC"
  },
  {
    "descriptor": "TRX",
    "displayName": "TRON",
    "blockchainProtocolId": "TRX",
    "nativeAsset": "TRX"
  },
  {
    "descriptor": "DASH_TEST",
    "displayName": "Dash Testnet",
    "blockchainProtocolId": "BTC",
    "nativeAsset": "DASH_TEST"
  },
  {
    "descriptor": "BLINC_EUR",
    "displayName": "BLINC by BCB Group",
    "blockchainProtocolId": "BANK",
    "nativeAsset": "BLINC_EUR"
  },
  {
    "descriptor": "ZIRCUIT_ETH_TEST",
    "displayName": "Zircuit Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ZIRCUIT_ETH_TEST"
  },
  {
    "descriptor": "ASIANXT_BESU",
    "displayName": "AsiaNext Besu",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ASIANXT_BESU"
  },
  {
    "descriptor": "ATOM_COS",
    "displayName": "Cosmos Hub",
    "blockchainProtocolId": "COSMOS",
    "nativeAsset": "ATOM_COS"
  },
  {
    "descriptor": "CELO_BAKLAVA",
    "displayName": "Celo Baklava Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "CELO_BAK"
  },
  {
    "descriptor": "NEAR",
    "displayName": "NEAR Protocol",
    "blockchainProtocolId": "NEAR",
    "nativeAsset": "NEAR"
  },
  {
    "descriptor": "EOS_TEST",
    "displayName": "EOS.IO Testnet",
    "blockchainProtocolId": "EOS",
    "nativeAsset": "EOS_TEST"
  },
  {
    "descriptor": "ETH_TEST3",
    "displayName": "Ethereum Testnet Goerli",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ETH_TEST3"
  },
  {
    "descriptor": "CBS_TEST",
    "displayName": "ANZ Test Avalanche Subnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "CBS_TEST"
  },
  {
    "descriptor": "GNOSIS_TEST",
    "displayName": "Gnosis Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "XDAI_TEST"
  },
  {
    "descriptor": "BCH",
    "displayName": "Bitcoin Cash",
    "blockchainProtocolId": "BTC",
    "nativeAsset": "BCH"
  },
  {
    "descriptor": "VICTION",
    "displayName": "Viction",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "VICTION"
  },
  {
    "descriptor": "DV4TNT_TEST",
    "displayName": "DYDX Testnet",
    "blockchainProtocolId": "COSMOS",
    "nativeAsset": "DV4TNT_TEST"
  },
  {
    "descriptor": "USDC_NOBLE_TEST",
    "displayName": "USDC Noble Testnet",
    "blockchainProtocolId": "COSMOS",
    "nativeAsset": "USDC_NOBLE_TEST"
  },
  {
    "descriptor": "MOVR",
    "displayName": "Moonriver",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "MOVR_MOVR"
  },
  {
    "descriptor": "BLINC_TEST_EUR",
    "displayName": "BLINC Test",
    "blockchainProtocolId": "BANK",
    "nativeAsset": "BLINC_TEST_EUR"
  },
  {
    "descriptor": "BTC_TEST",
    "displayName": "Bitcoin Testnet",
    "blockchainProtocolId": "BTC",
    "nativeAsset": "BTC_TEST"
  },
  {
    "descriptor": "ZKEVM_TEST",
    "displayName": "zkEVM Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ETH_ZKEVM_TEST"
  },
  {
    "descriptor": "LUNA",
    "displayName": "Terra Classic",
    "blockchainProtocolId": "TERRA",
    "nativeAsset": "LUNA"
  },
  {
    "descriptor": "TASE_LIVE",
    "displayName": "TASE Production LIVE Network",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "TASE_LIVE"
  },
  {
    "descriptor": "ARB",
    "displayName": "Arbitrum One",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ETH-AETH"
  },
  {
    "descriptor": "UNICHAIN_ETH",
    "displayName": "Unichain",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "UNICHAIN_ETH"
  },
  {
    "descriptor": "PT3_TEST",
    "displayName": "Private Token 3",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "PT3_TEST"
  },
  {
    "descriptor": "OAS",
    "displayName": "Oasys",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "OAS"
  },
  {
    "descriptor": "HT_TEST",
    "displayName": "HT Chain Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "HT_CHAIN_TEST"
  },
  {
    "descriptor": "BITKUB",
    "displayName": "Bitkub Chain",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "KUB_BITKUB"
  },
  {
    "descriptor": "XDC",
    "displayName": "XinFin Network",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "XDC"
  },
  {
    "descriptor": "SNC_DEV",
    "displayName": "dSNC",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "SNC_DEV"
  },
  {
    "descriptor": "SEN_USD",
    "displayName": "SEN by Silvergate",
    "blockchainProtocolId": "BANK",
    "nativeAsset": "SEN_USD"
  },
  {
    "descriptor": "ECS_TEST",
    "displayName": "eCredits Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "ECS_TEST"
  },
  {
    "descriptor": "BERACHAIN_ARTIO_TEST",
    "displayName": "Berachain Artio Test",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "BERACHAIN_ARTIO_TEST"
  },
  {
    "descriptor": "FASTEX_BAHAMUT",
    "displayName": "Fastex Bahamut",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "FASTEX_BAHAMUT"
  },
  {
    "descriptor": "TELOS_TEST",
    "displayName": "Telos EVM Test",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "TELOS_TEST"
  },
  {
    "descriptor": "CODEFI_CNVAS",
    "displayName": "Codefi",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "CODEFI_CNVAS"
  },
  {
    "descriptor": "INJ_TEST",
    "displayName": "Injective Testnet",
    "blockchainProtocolId": "COSMOS",
    "nativeAsset": "INJ_TEST"
  },
  {
    "descriptor": "JCY_TEST",
    "displayName": "JCY Private Network (Test)",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "JCY_TEST"
  },
  {
    "descriptor": "CAMINO",
    "displayName": "Camino",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "CAMINO"
  },
  {
    "descriptor": "SIGNET_USD",
    "displayName": "Signet by Signature",
    "blockchainProtocolId": "BANK",
    "nativeAsset": "SIGNET_USD"
  },
  {
    "descriptor": "REDBELLY_TEST",
    "displayName": "Redbelly Test",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "REDBELLY_TEST"
  },
  {
    "descriptor": "CBDC_DEV",
    "displayName": "CBDC Devnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "CBDC_DEV"
  },
  {
    "descriptor": "ALGO_TEST",
    "displayName": "Algorand Testnet",
    "blockchainProtocolId": "ALGO",
    "nativeAsset": "ALGO_TEST"
  },
  {
    "descriptor": "SOL_TEST",
    "displayName": "Solana Devnet",
    "blockchainProtocolId": "SOL",
    "nativeAsset": "SOL_TEST"
  },
  {
    "descriptor": "PEERACCOUNTTRANSFER_EUR",
    "displayName": "EUR (Peer Transfer)",
    "blockchainProtocolId": "BANK",
    "nativeAsset": "PEERACCOUNTTRANSFER_EUR"
  },
  {
    "descriptor": "CELO_ALFAJORES",
    "displayName": "Celo Alfajores Testnet",
    "blockchainProtocolId": "ETH",
    "nativeAsset": "CELO_ALF"
  }
]
"""
}