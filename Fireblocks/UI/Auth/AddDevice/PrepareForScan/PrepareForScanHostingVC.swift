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
        print(address)
    }
}

extension PrepareForScanHostingVC: PrepareForScanDelegate {
    func scanQR() {
        let vc = QRCodeScannerViewController(nibName: "QRCodeScannerViewController", bundle: nil)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
