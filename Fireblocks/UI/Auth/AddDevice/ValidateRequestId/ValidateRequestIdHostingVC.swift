//
//  ValidateRequestIdHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import Foundation
import SwiftUI

class ValidateRequestIdHostingVC: FBHostingViewController {
    let viewModel: ValidateRequestIdViewModel
    init(requestId: String) {
        self.viewModel = ValidateRequestIdViewModel(requestId: requestId)
        let view = ValidateRequestIdView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
