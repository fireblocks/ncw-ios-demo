//
//  StartJoinDeviceFlowView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI
import FirebaseAuth

struct StartJoinDeviceFlowView: View {
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager
    @StateObject var viewModel = ViewModel()
    @Binding var showLoader: Bool
    @Binding var path: NavigationPath
    
    var body: some View {
        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceImage.rawValue, title: LocalizableStrings.addNewDeviceNavigationBar, subTitle: LocalizableStrings.mpcKeysAddDeviceTitle, buttonTitle: LocalizableStrings.continueTitle, actionButton: {
            viewModel.addDeviceFromSdk()
        }, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
            viewModel.signOut()
        }), content: 
                AnyView(InnerAlertBannerView(message: bannerErrorsManager.errorMessage))
            
        )
        .onAppear() {
            viewModel.setup(appRootManager: appRootManager, bannerErrorsManager: bannerErrorsManager)
        }
        .onChange(of: viewModel.showLoader) { value in
            showLoader = value
        }
        .onChange(of: viewModel.addDeviceQRViewModel) { value in
            if let value {
                path.append(value)
            }
        }
        .onChange(of: viewModel.navigationType) { value in
            if let value {
                showLoader = false
                path.append(value)
            }
        }
        .animation(.default, value: bannerErrorsManager.errorMessage)
    }
}


//#Preview {
//    StartJoinDeviceFlowView()
//}
