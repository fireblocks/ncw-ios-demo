//
//  GenerateKeysView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/02/2025.
//

import SwiftUI

struct GenerateKeysView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @StateObject var viewModel: ViewModel
    init() {
        _viewModel = StateObject(wrappedValue: ViewModel())
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 16) {
                Image(.generateKeys)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                VStack {
                    Text("Generate MPC Keys")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    Text("We use multi-party computation (MPC) keys to provide the highest level of wallet security. MPCs allow for different parties to hold a piece of a private key without possessing the entire thing.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 40)
                    
                    VStack(spacing: 24) {
#if DEV
                        HStack(spacing: 24) {
                            Button {
                                viewModel.generateECDSAKeys()
                            } label: {
                                Text("EcDSA")
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(.thinMaterial, in: .capsule)
                            .foregroundStyle(.primary)
                            .contentShape(.rect)
                            Button {
                                viewModel.generateEDDSAKeys()
                            } label: {
                                Text("EdDSA")
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(.thinMaterial, in: .capsule)
                            .foregroundStyle(.primary)
                            .contentShape(.rect)
                            
                        }
#endif
                        
                        Button {
                            viewModel.generateMpcKeys()
                        } label: {
                            Text("Genertae keys")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(.thinMaterial, in: .capsule)
                        .foregroundStyle(.primary)
                        .contentShape(.rect)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, fireblocksManager: fireblocksManager, coordinator: coordinator)
        }
    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            GenerateKeysView()
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
                .environmentObject(AppleSignInManager())

        }
    }
}
