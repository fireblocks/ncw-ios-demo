//
//  SendToViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import Foundation

protocol SendToViewModelDelegate: AnyObject {
    func addressIsValid(isValid: Bool)
}

@Observable
class SendToViewModel: QRCodeScannerViewControllerDelegate {
    var coordinator: Coordinator?
    var loadingManager: LoadingManager?
    var isQRPresented = false
    
    weak var delegate: SendToViewModelDelegate?
    var address: String = ""
    var transaction: FBTransaction
    
    init(transaction: FBTransaction = FBTransaction()) {
        self.transaction = transaction
    }
    
    func presentQRCodeScanner() {
        self.isQRPresented = true
    }
    
    //MARK: QRCodeScannerViewControllerDelegate -
    static func == (lhs: SendToViewModel, rhs: SendToViewModel) -> Bool {
        lhs.address == rhs.address
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }

    func setup(loadingManager: LoadingManager, coordinator: Coordinator) {
        self.coordinator = coordinator
        self.loadingManager = loadingManager
    }
    
    @MainActor
    func gotAddress(address: String) {
        isQRPresented = false
        self.setAddress(address: address)
    }

    func isAddressValid() -> Bool {
        return !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func setAddress(address: String){
        self.address = address
    }
    
    func proceedToFee() {
        if let transaction = getTransaction() {
            coordinator?.path.append(NavigationTypes.selectFee(transaction))
        }
    }
    
    func getAmountToSendAsString() -> String {
        return String(transaction.amountToSend)
    }
    
    func getPriceAsString() -> String {
        return "$\(transaction.price.formatFractions(fractionDigits: 2))"
    }
    
    
    func getTransaction() -> FBTransaction? {
        transaction.receiverAddress = address
        
        return transaction
    }

    func getAsset() -> AssetSummary? {
        return transaction.asset
    }
}
