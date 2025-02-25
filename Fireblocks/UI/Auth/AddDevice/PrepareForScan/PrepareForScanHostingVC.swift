//
//  PrepareForScanHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
import SwiftUI

protocol PrepareForScanDelegate: AnyObject {
    func scanQR()
}

struct PrepareForScanHostingVCRep: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PrepareForScanHostingVC {
        return PrepareForScanHostingVC()
    }

    func updateUIViewController(_ uiViewController: PrepareForScanHostingVC, context: Context) {
    }
}

class PrepareForScanHostingVC: FBHostingViewController {
    let viewModel: PrepareForScanViewModel
    init() {
        self.viewModel = PrepareForScanViewModel()
        let view = PrepareForScanView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInit() {
        self.viewModel.delegate = self
        self.viewModel.prepareDelegate = self
    }
}

extension PrepareForScanHostingVC: QRCodeScannerViewControllerDelegate {
    func gotAddress(address: String) {
        guard let _ = viewModel.qrData(encoded: address.base64Decoded() ?? "") else {
            viewModel.error = "Missing request ID. Go back and try again"
            return
        }
        let vc = ValidateRequestIdHostingVC(requestId: address)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PrepareForScanHostingVC: PrepareForScanDelegate {
    func scanQR() {
        let vc = QRCodeScannerViewController(delegate: self)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
