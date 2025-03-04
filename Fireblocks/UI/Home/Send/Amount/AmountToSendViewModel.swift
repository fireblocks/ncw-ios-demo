//
//  AmountToSendViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 21/06/2023.
//

import Foundation

protocol AmountToSendViewModelDelegate: AnyObject {
    func amountAndSumChanged(amount: String, price: String)
    func isAmountInputValid(isValid: Bool, errorMessage: String?)
}

class AmountToSendViewModel {
    
//MARK: - PROPERTIES
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    
    weak var delegate: AmountToSendViewModelDelegate?
    var asset: AssetSummary
    private var assetAmount: Double {
        get {
            return Double(assetAmountString) ?? 0
        }
    }
    private var assetAmountString: String = "0"
    private var calculatedPrice: Double = 0
    private var isDecimalEntered = false
    
    init(asset: AssetSummary = AssetSummary()) {
        self.asset = asset
        self.asset.isExpanded = false
    }
    
//MARK: - Functions
    func addDote(){
        if !isDecimalEntered {
            assetAmountString += "."
            isDecimalEntered = true
        }
        
        calculatePrice()
        checkAmountIsValid()
    }
    
    func addNumber(number: Int){
        if number == 0 {
            if assetAmountString != "0" {
                assetAmountString += "\(number)"
            }
        } else {
            if assetAmountString == "0" {
                assetAmountString = "\(number)"
            } else {
                assetAmountString += "\(number)"
            }
        }
        
        calculatePrice()
        checkAmountIsValid()
    }
    
    func eraseNumber(){
        if assetAmountString.count == 1 {
            assetAmountString = "0"
            delegate?.isAmountInputValid(isValid: false, errorMessage: nil)
        } else {
            if let last = assetAmountString.last, last == "." {
                isDecimalEntered = false
            }
            assetAmountString = String(assetAmountString.dropLast())
            checkAmountIsValid()
        }
        
        calculatePrice()
    }
    
    func setMaxAmount(){
        if let balance = asset.balance?.total {
            assetAmountString = "\(balance)"
        }
        if assetAmountString.contains(".") {
            isDecimalEntered = true
        } else {
            isDecimalEntered = false
        }
        
        calculatePrice()
        checkAmountIsValid()
    }
    
    func getAsset() -> AssetSummary {
        return asset
    }
    
    private func calculatePrice(){
        #if EW
        if let assetId = asset.asset?.id {
            calculatedPrice = CryptoCurrencyManager.shared.getPrice(assetId: assetId, amount: assetAmount).formatFractions(fractionDigits: 5)
        }
        #else
        if let rate = asset.asset?.rate {
            calculatedPrice = (assetAmount * rate).formatFractions(fractionDigits: 2)
        }
        #endif
        updateUI()
    }
    
    private func checkAmountIsValid(){
        if let total = asset.balance?.total, let balance = Double(total) {
            let isValid = assetAmount <= balance && assetAmount != 0
            updateUIIsAmountValid(isValid: isValid)
        }
    }
    
    private func updateUIIsAmountValid(isValid: Bool){
        let errorMessage = isValid ? nil : "You have \(asset.balance?.total ?? "0.0") \(asset.asset?.symbol ?? "") available."
        delegate?.isAmountInputValid(isValid: isValid, errorMessage: errorMessage)
    }
    
    private func updateUI(){
        delegate?.amountAndSumChanged(amount: "\(assetAmountString) \(asset.asset?.symbol ?? "")", price: "$\(calculatedPrice)")
    }
    
    func createTransaction() -> FBTransaction {
        return FBTransaction(asset: asset,
                           amountToSend: assetAmount,
                           price: calculatedPrice)
    }
}
