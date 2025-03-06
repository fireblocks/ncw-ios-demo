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
        lhs.requestId == rhs.requestId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(requestId)
    }

    var coordinator: Coordinator?
    var loadingManager: LoadingManager?

    var isQRPresented: Bool = false
    var requestId: String = ""

    weak var prepareDelegate: PrepareForScanDelegate?

    func setup(coordinator: Coordinator, loadingManager: LoadingManager) {
        self.coordinator = coordinator
        self.loadingManager = loadingManager
    }
    
    @MainActor
    func sendRequestId() {
        if !requestId.isTrimmedEmpty, let _ = qrData(encoded: requestId.base64Decoded() ?? "") {
            self.gotAddress(address: requestId)
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
        guard let _ = qrData(encoded: address.base64Decoded() ?? "") else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
            return
        }
        
        guard !requestId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
            return
        }
        coordinator?.path.append(NavigationTypes.validateRequestIdView(requestId))
    }

}
