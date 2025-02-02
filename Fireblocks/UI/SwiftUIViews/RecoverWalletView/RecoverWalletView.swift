//
//  RecoverWalletView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

struct RecoverWalletView: View {
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
                    Text("Recover Wallet")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    Text("Recover keys from where you last saved them.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 40)
                    
                    Button {
                        viewModel.recover()
                    } label: {
                        Label("Recover from Drive", image: "google_icon")
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
        .navigationBarItems(leading: CustomBackButtonView())
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, fireblocksManager: fireblocksManager, googleSignInManager: googleSignInManager)
        }
        .onChange(of: viewModel.dismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            RecoverWalletView(redirect: false)
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
                .environmentObject(AppleSignInManager())

        }
    }
}

