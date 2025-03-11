//
//  PrepareForScanViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import Foundation

protocol PrepareForScanDelegate: AnyObject {
    func scanQR()
}

@Observable
class PrepareForScanViewModel: QRCodeScannerViewControllerDelegate {
    static func == (lhs: PrepareForScanViewModel, rhs: PrepareForScanViewModel) -> Bool {
        lhs.qrCode == rhs.qrCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(qrCode)
    }

    var coordinator: Coordinator?
    var loadingManager: LoadingManager?

    var isQRPresented: Bool = false
    var qrCode: String = ""

    weak var prepareDelegate: PrepareForScanDelegate?

    func setup(coordinator: Coordinator, loadingManager: LoadingManager) {
        self.coordinator = coordinator
        self.loadingManager = loadingManager
    }
    
    @MainActor
    func sendRequestId() {
        if !qrCode.isTrimmedEmpty {
            self.gotAddress(address: qrCode)
        } else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
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
        self.isQRPresented = true
    }
    
    @MainActor
    func gotAddress(address: String) {
        self.isQRPresented = false
        guard let data = qrData(encoded: address.base64Decoded() ?? "") else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
            return
        }
        
        guard !address.isEmpty else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
            return
        }
        coordinator?.path.append(NavigationTypes.validateRequestIdView(address))
    }

}
