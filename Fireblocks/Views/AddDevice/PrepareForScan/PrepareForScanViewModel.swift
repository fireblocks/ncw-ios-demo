//
//  PrepareForScanViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import Foundation

class PrepareForScanViewModel: ObservableObject, Hashable {
    static func == (lhs: PrepareForScanViewModel, rhs: PrepareForScanViewModel) -> Bool {
        return lhs.requestId == rhs.requestId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(requestId)
    }

    var didAppear: Bool = false
    @Published var requestId: String = ""
    @Published var error: String?
    @Published var vc: QRCodeScannerRep?
    @Published var navigationType: NavigationTypes?

    func sendRequestId() {
        if !requestId.isTrimmedEmpty, let _ = qrData(encoded: requestId.base64Decoded() ?? "") {
            self.gotAddress(address: requestId)
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
        vc = QRCodeScannerRep(delegate: self)
        
    }
}

extension PrepareForScanViewModel: QRCodeScannerViewControllerDelegate {
    func gotAddress(address: String) {
        guard let _ = qrData(encoded: address.base64Decoded() ?? "") else {
            error = "Missing request ID. Go back and try again"
            return
        }
        navigationType = .ValidateRequestId(address)
    }
}
