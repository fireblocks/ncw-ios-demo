//
//  AmountToSendViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 21/06/2023.
//

import Foundation

protocol AmountToSendViewModelDelegate: AnyObject {
    func amountAndSumChanged(amount: String, price: String)
    func isAmountInputValid(isValid: Bool, errorMessage: String?, amount: Double)
}

class AmountToSendViewModel {
    
//MARK: - PROPERTIES
    weak var delegate: AmountToSendViewModelDelegate?
    var asset: Asset!
    private var assetAmount: Double {
        get {
            return Double(assetAmountString) ?? 0
        }
    }
    private var assetAmountString: String = "0"
    private var calculatedPrice: Double = 0
    private var isDecimalEntered = false
    
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
            delegate?.isAmountInputValid(isValid: true, errorMessage: nil, amount: 0)
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
        if let balance = asset.balance {
            assetAmountString = "\(balance)"
        }
        isDecimalEntered = true
        
        calculatePrice()
        checkAmountIsValid()
    }
    
    func getAsset() -> Asset {
        return asset
    }
    
    private func calculatePrice(){
        if let rate = asset.rate {
            calculatedPrice = (assetAmount * rate).formatFractions(fractionDigits: 2)
        }
        updateUI()
    }
    
    private func checkAmountIsValid(){
        if let balance = asset.balance {
            if assetAmount == 0 {
                updateUIIsAmountValid(isValid: true, amount: 0)
                return
            }
            updateUIIsAmountValid(isValid: assetAmount <= balance, amount: assetAmount)
        }
    }
    
    private func updateUIIsAmountValid(isValid: Bool, amount: Double){
        let errorMessage = isValid ? nil : "You have \(asset.balance ?? 0.0) \(asset.symbol) available."
        delegate?.isAmountInputValid(isValid: isValid, errorMessage: errorMessage, amount: amount)
    }
    
    private func updateUI(){
        delegate?.amountAndSumChanged(amount: "\(assetAmountString) \(asset.symbol)", price: "$\(calculatedPrice.formatFractions(fractionDigits: 2))")
    }
    
    func createTransaction() -> Transaction {
        return Transaction(asset: asset,
                           amountToSend: assetAmount,
                           price: calculatedPrice)
    }
}
