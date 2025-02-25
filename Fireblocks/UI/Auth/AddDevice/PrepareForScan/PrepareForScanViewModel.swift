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
    @Published var error: String?

    weak var delegate: (any QRCodeScannerViewControllerDelegate)?
    weak var prepareDelegate: PrepareForScanDelegate?

    func sendRequestId() {
        if !requestId.isTrimmedEmpty, let _ = qrData(encoded: requestId.base64Decoded() ?? "") {
            self.delegate?.gotAddress(address: requestId)
        } else {
            self.error = "Missing request ID. Go back and try again"
        }
    }
    
    func qrData(encoded: String) -> JoinRequestData? {
        if let data = encoded.data(using: .utf8) {
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(JoinRequestData.self, from: data)
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }

    
    func scanQR() {
        self.error = nil
        self.prepareDelegate?.scanQR()
    }
}
