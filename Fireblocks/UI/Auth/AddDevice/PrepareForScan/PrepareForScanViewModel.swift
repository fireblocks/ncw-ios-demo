//
//  PrepareForScanViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import Foundation

class PrepareForScanViewModel: ObservableObject, UIHostingBridgeNotifications {
    var didAppear: Bool = false
    @Published var requestId: String = ""
    weak var delegate: QRCodeScannerViewControllerDelegate?
    weak var prepareDelegate: PrepareForScanDelegate?

    func sendRequestId() {
        if !requestId.isTrimmedEmpty {
            self.delegate?.gotAddress(address: requestId)
        }
    }
    
    func scanQR() {
        self.prepareDelegate?.scanQR()
    }
}
