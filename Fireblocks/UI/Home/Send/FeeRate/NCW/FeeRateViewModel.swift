//
//  FeeRateViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import Foundation
import Combine
final class FeeRateViewModel {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    
    //MARK: - PROPERTIES
    var transaction: FBTransaction
    private var fees: [Fee] = []
    private var selectedFeeIndex: Int = 0
    private let repository = FeeRateRepository()
    private var tasks: [Task<Void, Never>]?
    weak var delegate: FeeRateViewModelDelegate?
    private var transactionID: String?
    private var didPresented = false
    private var cancellable = Set<AnyCancellable>()
    
    init(transaction: FBTransaction = FBTransaction()) {
        self.transaction = transaction
    }
    
    //MARK: - FUNCTIONS
    deinit {
        cancellable.removeAll()
        tasks?.forEach{ $0.cancel() }
    }
    
    func isContinueButtonEnabled() -> Bool {
        if fees.count == 0 { return false }
        
        return true
    }
    
    func fetchFeeRates(){
        guard let destAddress = transaction.receiverAddress else { return }
        let assetId = transaction.asset.id
        let amount = transaction.amountToSend
        
        Task {
            do {
                await self.loadingManager?.setLoading(value: true)
                fees = try await repository.getFeeRates(for: assetId, amount: "\(amount)", address: destAddress)
                await self.loadingManager?.setLoading(value: false)
                delegate?.refreshData()
            } catch let error {
                await self.loadingManager?.setLoading(value: false)
                await self.loadingManager?.setAlertMessage(error: error)
                delegate?.isTransactionCreated(isCreated: false)
            }
        }
    }
    
    func getFees() -> [Fee] {
        fees
    }
    
    func getFeesCount() -> Int {
        fees.count
    }
    
    func getSelectedIndex() -> Int? {
        return selectedFeeIndex
    }
    
    func selectFee(at index: Int) {
        selectedFeeIndex = index
    }
    
    func getTransaction() -> FBTransaction? {
        if let txId = transactionID {
            if fees.count > selectedFeeIndex {
                transaction.fee = fees[selectedFeeIndex]
            } else {
                transaction.fee = nil
            }
            transaction.txId = txId
            return transaction
        } else {
            return nil
        }
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
        
        guard fees.count > selectedFeeIndex else {
            print("❌ selectedFeeIndex nil")
            return
        }
        
        
        let transactionParams = PostTransactionParams(assetId: transaction.asset.id, destAddress: receiverAddress,
                                                      amount: "\(transaction.amountToSend)",
                                                      note: "test transaction",
                                                      feeLevel: fees[selectedFeeIndex].feeRateType.rawValue)
        
        let task = Task {
            do {
                let response = try await repository.createTransaction(assetId: transaction.asset.id, transactionParams: transactionParams)
                self.transactionID = response.id
                listenToTransactionStatusChanges()
            } catch let error {
                await self.loadingManager?.setAlertMessage(error: error)
                self.delegate?.isTransactionCreated(isCreated: false)
            }
        }
        
        tasks?.append(task)
    }
    
    private func listenToTransactionStatusChanges() {
        if let transactionID = self.transactionID {
            let failedStatus: [Status] = [.failed, .blocked, .cancelled, .rejected]
            TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
                .sink { [weak self] transfers in
                    if let self {
                        if let transaction = transfers.first(where: {$0.transactionID == transactionID}) {
                            let status = transaction.status
                            if status == .pendingSignature, !self.didPresented {
                                self.didPresented = true
                                self.delegate?.isTransactionCreated(isCreated: true)
                            } else if failedStatus.contains(status) {
                                self.delegate?.isTransactionCreated(isCreated: false)
                            }
                        }
                    }
                }.store(in: &cancellable)
        }
    }
    
}
