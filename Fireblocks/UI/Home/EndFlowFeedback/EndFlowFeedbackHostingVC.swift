//
//  EndFlowFeedbackHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import Foundation
import SwiftUI

class EndFlowFeedbackHostingVC: FBHostingViewController {
    let viewModel: EndFlowFeedbackView.ViewModel
    init(icon: String? = nil, title: String? = nil, subTitle: String? = nil, didFail: Bool = false, navigationBarTitle: String = "", buttonIcon: UIImage? = nil, buttonTitle: String? = nil, rightToolbarItemIcon: String? = nil, rightToolbarItemAction: (() -> Void)? = nil, content: AnyView? = nil, actionButton: (() -> Void)? = nil) {
        self.viewModel = EndFlowFeedbackView.ViewModel(icon: icon, title: title, subTitle: subTitle, navigationBarTitle: navigationBarTitle, buttonIcon: buttonIcon, buttonTitle: buttonTitle, actionButton: actionButton, rightToolbarItemIcon: rightToolbarItemIcon, rightToolbarItemAction: rightToolbarItemAction, didFail: didFail, content: content)
        let view = EndFlowFeedbackView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
