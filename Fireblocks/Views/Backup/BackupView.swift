//
//  BackupView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct BackupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var authRepository: AuthRepository
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager
    @StateObject var viewModel = ViewModel()
    @Binding var showLoader: Bool
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                GenericHeaderView(icon: AssetsIcons.keyImage.rawValue, subtitle: viewModel.getBackupDetails())
                    .padding(.bottom, 16)
                LabeldButton(icon: Image(.googleIcon), title: "Backup on drive") {
                    viewModel.backup(backupProvider: .GoogleDrive)
                }
                
                LabeldButton(icon: Image(.appleIcon), title: "Backup on iCloud") {
                    viewModel.backup(backupProvider: .iCloud)
                }
                
                Spacer()
                
            }
            .padding(16)
            
            VStack {
                Spacer()
                AlertBannerView(message: bannerErrorsManager.errorMessage)
            }
            .padding(24)

        }
        .onChange(of: viewModel.showLoader) { value in
            showLoader = value
        }
        .onAppear() {
            viewModel.setup(appRootManager: appRootManager, authRepository: authRepository, bannerErrorsManager: bannerErrorsManager)
            viewModel.checkIfBackupExist()
        }
        .onChange(of: viewModel.navigationType) { value in
            if let value {
                showLoader = false
                path.append(value)
            }
        }
        .animation(.default, value: bannerErrorsManager.errorMessage)
        .addBridge(viewModel.bridge)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.removeLast()
                } label: {
                    Image(.back)
                }
                .tint(.primary)
            }
        }
        .navigationTitle(LocalizableStrings.createKeyBackup)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()

    }
}

//#Preview {
//    BackupView()
//}
