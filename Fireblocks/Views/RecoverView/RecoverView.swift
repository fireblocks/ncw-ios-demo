//
//  RecoverView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 12/03/2024.
//

import SwiftUI

struct RecoverView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var authRepository: AuthRepository
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager
    @StateObject var viewModel = ViewModel()
    @Binding var showLoader: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text(LocalizableStrings.chooseRecoveryLocation)
                    .font(.body1)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                if viewModel.backupProvider != nil {
                    LabeldButton(icon: viewModel.getRecoverButtonIcon(), title: viewModel.getRecoverButtonTitle()) {
                        Task {
                            await viewModel.recover()
                        }
                    }
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
        .addBridge(viewModel.bridge)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(AssetsIcons.back.rawValue)
                }
                .tint(.primary)
            }
        }
        .navigationTitle(LocalizableStrings.recoverWallet)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()
    }
}

//#Preview {
//    RecoverView()
//}
