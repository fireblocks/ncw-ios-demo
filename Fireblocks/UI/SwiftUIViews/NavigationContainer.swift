//
//  NavigationContainer.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 12/03/2024.
//

import SwiftUI
import FirebaseAuth

enum NavigationTypes: Hashable {
    case Recover(Bool)
    case Backup(Bool)
    case GenerateSucceeded
    case BackupSucceeded(Bool)
    case JoinDeviceSucceeded
    case JoinDeviceFailed
    case JoinDevicetimeExpired
    case AddDeviceSucceeded
    case AddDeviceCanceled
    case AddDevicetimeExpired
    case Settings
    case AdvancedInfo
    case AddDevice
    case ValidateRequestId(String)
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
                    case .Recover(let isFirstRecover):
                        RecoverView(showLoader: $showLoader, path: $path, isFirstRecover: isFirstRecover)
                    case .Backup(let isFirstBackup):
                        BackupView(showLoader: $showLoader, path: $path, isFirstBackup: isFirstBackup)
                    case .GenerateSucceeded:
                        GenerateKeysSucceeded(path: $path)
                    case .BackupSucceeded(let isFirstBackup):
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.keyImage.rawValue, subTitle: "Your recovery key is backed up!", buttonIcon: AssetsIcons.home.getIcon(), buttonTitle: LocalizableStrings.goHome, actionButton:  {
                            if isFirstBackup {
                                self.appRootManager.currentRoot = .assets
                            } else {
                                path = NavigationPath()
                            }
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
                    case .Settings:
                        SettingsView(path: $path)
                    case .AdvancedInfo:
                        AdvancedInfoView(path: $path)
                    case .AddDevice:
                        PrepareForScanView(path: $path)
                    case .ValidateRequestId(let requestId):
                        ValidateRequestIdView(requestId: requestId, showLoader: $showLoader, path: $path)
                        
                    case .AddDeviceSucceeded:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceSucceeded.rawValue, title: LocalizableStrings.approveJoinWalletSucceeded, buttonTitle: LocalizableStrings.goHome, actionButton:  {
                            path = NavigationPath()
                        }), content: nil)
                    case .AddDeviceCanceled:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.addDeviceFailed.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, subTitle: LocalizableStrings.approveJoinWalletCanceledSubtitle, buttonTitle: LocalizableStrings.goHome, actionButton:  {
                            path = NavigationPath()
                        }, didFail: true), content: nil)
                    case .AddDevicetimeExpired:
                        EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, buttonTitle: LocalizableStrings.tryAgain, actionButton:  {
                            path.removeLast(path.count - 1)
                        }, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
                            path.append(NavigationTypes.AddDeviceCanceled)
                        }, didFail: true), content: AnyView(ValidateRequestIdTimeOutView()))
                    }
                }
                .navigationDestination(for: AddDeviceQRViewModel.self) { viewModel in
                    AddDeviceQRView(viewModel: viewModel, toast: $toast, showLoader: $showLoader, path: $path)
                }
                .navigationDestination(for: PrepareForScanViewModel.self) { vc in
                    QRCodeScannerRep(delegate: vc)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    path.removeLast()
                                } label: {
                                    Image(uiImage: AssetsIcons.back.getIcon())
                                }
                                .tint(.primary)
                            }
                        }
                        .navigationTitle("Scan QR")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden()
                }
            

        }
    }
}
