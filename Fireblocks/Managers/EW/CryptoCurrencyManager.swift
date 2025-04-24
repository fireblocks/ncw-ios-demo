//
//  CryptoCurrencyManager.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 28/01/2025.
//

class CryptoCurrencyManager {
    static let shared = CryptoCurrencyManager()
    private init() {}
    
    func getTotalPrice(assetId: String, networkProtocol: String?, amount: Double) -> String {
        if let data = CryptoCurrencyData.cryptoCurrency.data(using: .utf8) {
            if let cryptoCurrecnyData: CryptoCurrency = try? GenericDecoder.decode(data: data) {
                let formattedSymbol = AssetImageLoader.shared.getFormattedSymbol(assetId: assetId)
                if let rate = cryptoCurrecnyData.data.first(where: {$0.symbol == formattedSymbol})?.quote.USD.price {
                    let totalPrice = amount * rate
                    
                    return "$\(totalPrice.formatFractions(fractionDigits: 2))"
                } else if let networkProtocol, let rate = cryptoCurrecnyData.data.first(where: {$0.symbol == networkProtocol})?.quote.USD.price {
                    let totalPrice = amount * rate
                    
                    return "$\(totalPrice.formatFractions(fractionDigits: 2))"
                }
            }
        }
        return "$\(amount.formatFractions(fractionDigits: 2))"

    }
    
    func getPrice(assetId: String, networkProtocol: String?, amount: Double) -> Double {
        if let data = CryptoCurrencyData.cryptoCurrency.data(using: .utf8) {
            if let cryptoCurrecnyData: CryptoCurrency = try? GenericDecoder.decode(data: data) {
                let formattedSymbol = AssetImageLoader.shared.getFormattedSymbol(assetId: assetId)
                if let rate = cryptoCurrecnyData.data.first(where: {$0.symbol == formattedSymbol})?.quote.USD.price {
                    let totalPrice = amount * rate
                    
                    return totalPrice
                } else if let networkProtocol, let rate = cryptoCurrecnyData.data.first(where: {$0.symbol == networkProtocol})?.quote.USD.price {
                    let totalPrice = amount * rate
                    
                    return totalPrice
                }
            }
        }
        return amount

    }
}
