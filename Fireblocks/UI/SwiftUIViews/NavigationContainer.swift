//
//  NavigationContainer.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 12/03/2024.
//

import SwiftUI
import FirebaseAuth

enum NavigationTypes {
    case Recover
    case Backup
    case FirstBackup
    case JoinDeviceSucceeded
    case JoinDeviceFailed
    case JoinDevicetimeExpired
    case BackupSucceeded
}

struct NavigationContainer<NavigationContent: View>: View {
    @EnvironmentObject var appRootManager: AppRootManager
    @Binding var path: NavigationPath
    @Binding var showLoader: Bool
    @Binding var toast: String?
    
    @ViewBuilder var navigationContent: NavigationContent

    var body: some View {
        NavigationStack(path: $path) {
            navigationContent
                .navigationDestination(for: NavigationTypes.self) { selection in
                    switch selection {
                    case .Recover:
                        RecoverView(showLoader: $showLoader)
                    case .Backup:
                        BackupView(showLoader: $showLoader, path: $path)
                    case .FirstBackup:
                        GenerateKeysSucceeded(path: $path)
                    case .BackupSucceeded:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.keyImage.rawValue, subTitle: "Your recovery key is backed up!", buttonIcon: AssetsIcons.home.getIcon(), buttonTitle: LocalizableStrings.goHome, actionButton:  {
                            self.appRootManager.currentRoot = .assets
                        }), content: nil)

                    case .JoinDeviceSucceeded:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceSucceeded.rawValue, title: LocalizableStrings.addDeviceAdded, buttonIcon: AssetsIcons.home.getIcon(), buttonTitle: LocalizableStrings.goHome, actionButton:  {
                            self.appRootManager.currentRoot = .assets
                        }), content: nil)
                    case .JoinDeviceFailed:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceFailed.rawValue, title: LocalizableStrings.addDeviceFailedTitle, subTitle: LocalizableStrings.addDeviceFailedSubtitle, buttonIcon: AssetsIcons.home.getIcon(), buttonTitle: LocalizableStrings.goHome, actionButton:  {
                            self.path = NavigationPath()
                        }, didFail: true), content: nil)
                    case .JoinDevicetimeExpired:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, buttonTitle: LocalizableStrings.tryAgain, actionButton: {
                            self.path = NavigationPath()
                        }, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
                            try? Auth.auth().signOut()
                            self.appRootManager.currentRoot = .login
                        }, didFail: true), content: AnyView(ValidateRequestIdTimeOutView()))


                    }
                }
                .navigationDestination(for: AddDeviceQRViewModel.self) { viewModel in
                    AddDeviceQRView(viewModel: viewModel, toast: $toast, showLoader: $showLoader, path: $path)
                }
            

        }
    }
}
