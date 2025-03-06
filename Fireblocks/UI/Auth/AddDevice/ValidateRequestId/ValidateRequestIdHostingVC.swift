//
//  ValidateRequestIdHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
import SwiftUI
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

class ValidateRequestIdHostingVC: FBHostingViewController {
    init(requestId: String) {
        let view = ValidateRequestIdView(viewModel: ValidateRequestIdViewModel(requestId: requestId))
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ValidateRequestIdHostingVC: ValidateRequestIdDelegate {
    func didApproveJoinWallet() {
        let vc = EndFlowFeedbackHostingVC(icon: AssetsIcons.addDeviceSucceeded.rawValue, title: LocalizableStrings.approveJoinWalletSucceeded, buttonTitle: LocalizableStrings.goHome, actionButton:  {
            self.navigationController?.popToRootViewController(animated: true)
        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didCancelJoinWallet() {
        let vc = EndFlowFeedbackHostingVC(icon: AssetsIcons.addDeviceFailed.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, subTitle: LocalizableStrings.approveJoinWalletCanceledSubtitle, didFail: true, buttonTitle: LocalizableStrings.goHome, actionButton:  {
            self.navigationController?.popToRootViewController(animated: true)
        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didApproveJoinWalletTimeExpired() {
        let vc = EndFlowFeedbackHostingVC(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, didFail: true, buttonTitle: LocalizableStrings.tryAgain, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
            self.didCancelJoinWallet()
        }, content: AnyView(ValidateRequestIdTimeOutView())) {
            if let targetVC = self.navigationController?.viewControllers.first(where: {$0 is PrepareForScanHostingVC}) {
                self.navigationController?.popToViewController(targetVC, animated: true)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
