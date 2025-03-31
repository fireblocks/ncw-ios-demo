//
//  FeeRateViewModelBase.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 07/03/2025.
//

import SwiftUI
import Combine

@Observable
class FeeRateViewModelBase {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    
    //MARK: - PROPERTIES
    var transaction: FBTransaction
    private var fees: [Fee] = []
    var selectedFee: Fee?
    var repository: FeeRateRepository?
    var transactionID: String?
    var cancellable = Set<AnyCancellable>()
    var didLoad = false
    
    init(transaction: FBTransaction = FBTransaction()) {
        self.transaction = transaction
    }
    
    //MARK: - FUNCTIONS
    deinit {
        cancellable.removeAll()
    }
    
    func fetchFeeRates() {
        guard let repository else { return }
        guard let destAddress = transaction.receiverAddress else { return }
        let assetId = transaction.asset.id
        let amount = transaction.amountToSend
        
        Task {
            do {
                await self.loadingManager?.setLoading(value: true)
                fees = try await repository.getFeeRates(for: assetId, amount: "\(amount)", address: destAddress)
                await self.loadingManager?.setLoading(value: false)
                if fees.isEmpty {
                    await self.loadingManager?.setAlertMessage(error: CustomError.genericError("No available fees"))
                } else {
                    self.selectedFee = fees.first(where: {$0.feeRateType == .LOW}) ?? fees.first
                }
            } catch let error {
                await self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }
    
    func getFees() -> [Fee] {
        fees
    }
    
    func getFee(fee: Fee) -> String {
        return fees.first(where: {$0.feeRateType == fee.feeRateType})?.fee ?? ""
    }
    
    func getSymbol() -> String {
        return transaction.asset.asset?.symbol ?? ""
    }
    
    func getFeesCount() -> Int {
        fees.count
    }
    
    func createTransaction(){
        guard transaction.asset.address != nil else {
            print("❌ senderAddress nil")
            return
        }
        
        guard let receiverAddress = transaction.receiverAddress else {
            print("❌ receiverAddress nil")
            return
        }
        
        guard let selectedFee else {
            print("❌ selectedFee nil")
            return
        }
        
        guard let repository else {
            print("❌ repository nil")
            return
        }
        
        
        let transactionParams = PostTransactionParams(assetId: transaction.asset.id, destAddress: receiverAddress,
                                                      amount: "\(transaction.amountToSend)",
                                                      note: "test transaction",
                                                      feeLevel: selectedFee.feeRateType.rawValue)
        
        Task {
            do {
                await self.loadingManager?.setLoading(value: true)
                let response = try await repository.createTransaction(assetId: transaction.asset.id, transactionParams: transactionParams)
                self.transactionID = response.id
                self.transaction.txId = response.id
                await MainActor.run {
                    listenToTransactionStatusChanges()
                }
            } catch let error {
                await self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }
    
    @MainActor
    func listenToTransactionStatusChanges() {
        fatalError("listenToTransactionStatusChanges should be implementd on child class")
    }

}
