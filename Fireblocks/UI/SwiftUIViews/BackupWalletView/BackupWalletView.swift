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
    @Environment(LoadingManager.self) var loadingManager
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
                Image(.createBackup)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                VStack {
                    Text(LocalizableStrings.backupYourKeys)
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    Text("Use the recovery key backup in case you lose access to your account.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 40)
                    
                    Button {
                        viewModel.backup()
                    } label: {
                        Label("Back up keys", image: "google_icon")
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
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if viewModel.redirect {
                        SignInViewModel.shared.launchView = NavigationContainerView {
                            TabBarView()
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(.backButton)

                }

            }
        })
        .navigationBarBackButtonHidden()
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


