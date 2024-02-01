//
//  AddDeviceHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
import SwiftUI

class AddDeviceHostingVC: FBHostingViewController {
    let viewModel: AddDeviceQRViewModel
    weak var delegate: MainSignOutDelegate?

    init(requestId: String, email: String, delegate: MainSignOutDelegate?) {
        self.viewModel = AddDeviceQRViewModel(requestId: requestId, email: email)
        self.delegate = delegate
        let view = AddDeviceQRView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInit() {
        viewModel.delegate = self
    }

}

extension AddDeviceHostingVC: AddDeviceQRDelegate {
    func didQRTimeExpired() {
        let vc = EndFlowFeedbackHostingVC(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, buttonTitle: LocalizableStrings.tryAgain, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
            self.delegate?.didSignOut()
        }, content: AnyView(ValidateRequestIdTimeOutView())) {
            self.navigationController?.popToRootViewController(animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
