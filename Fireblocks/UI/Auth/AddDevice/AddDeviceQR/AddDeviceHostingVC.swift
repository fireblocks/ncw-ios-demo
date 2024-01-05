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
    init(requestId: String, email: String) {
        self.viewModel = AddDeviceQRViewModel(requestId: requestId, email: email)
        let view = AddDeviceQRView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
