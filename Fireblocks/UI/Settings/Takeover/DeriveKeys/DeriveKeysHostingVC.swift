//
//  DeriveKeysHostingVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 06/03/2024.
//

import Foundation
import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

class DeriveKeysHostingVC: FBHostingViewController {
    let viewModel: DeriveKeysView.ViewModel

    init(privateKeys: Set<FullKey>) {
        self.viewModel = DeriveKeysView.ViewModel(privateKeys: privateKeys)
        let view = DeriveKeysView(viewModel: self.viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didInit() {
    }

}

