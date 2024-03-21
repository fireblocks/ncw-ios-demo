//
//  DeriveKeysHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 06/03/2024.
//

import Foundation
import SwiftUI

class DeriveKeysHostingVC: FBHostingViewController {
    let viewModel: DeriveKeysView.ViewModel

    init(privateKey: String) {
        self.viewModel = DeriveKeysView.ViewModel(privateKey: privateKey)
        let view = DeriveKeysView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInit() {
    }

}

