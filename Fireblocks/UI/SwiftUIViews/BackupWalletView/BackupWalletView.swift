//
//  BackupWalletView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/02/2025.
//

import SwiftUI

struct BackupWalletView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @EnvironmentObject var googleSignInManager: GoogleSignInManager
    @StateObject var viewModel: ViewModel
    init(redirect: Bool) {
        _viewModel = StateObject(wrappedValue: ViewModel(redirect: redirect))
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 16) {
                Image(.recoverWallet)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                VStack {
                    Text("Backup Wallet")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    Text("Backup your keys to Google Drive to recover your wallet.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 40)
                    
                    Button {
                        viewModel.backup()
                    } label: {
                        Label("Backup on Drive", image: "google_icon")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.horizontal)
                        
                    }
                    .background(.thinMaterial, in: .capsule)
                    .foregroundStyle(.primary)
                    .contentShape(.rect)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: viewModel.redirect ? CustomBackButtonView() : nil)
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, fireblocksManager: fireblocksManager, googleSignInManager: googleSignInManager, coordinator: coordinator)
        }
        .onChange(of: viewModel.dismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            BackupWalletView(redirect: false)
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
                .environmentObject(AppleSignInManager())

        }
    }
}


