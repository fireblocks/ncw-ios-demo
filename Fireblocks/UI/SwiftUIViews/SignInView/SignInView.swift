//
//  SignInView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var viewModel: SignInViewModel
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @EnvironmentObject var googleSignInManager: GoogleSignInManager
    @EnvironmentObject var appleSignInManager: AppleSignInManager

    @State var showMenu = false
    @State var error: Error?
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack {
                VStack {
                    Text("Welcome to Embedded Wallets")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 72)
                .padding(.bottom, 80)

                VStack(spacing: 24) {
                    Button {
                        viewModel.signInWithGoogle()
                    } label: {
                        Label("Sign in with Google", image: "google_icon")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.horizontal)
                        
                    }
                    .padding(.horizontal)
                    .background(AssetsColors.gray2.color(), in: .capsule)
                    .foregroundStyle(.primary)
                    .contentShape(.rect)
                    
                    Text("Or")
                        .foregroundStyle(.secondary)
                        .font(.b2)
                    Button {
                        viewModel.signInWithApple()
                    } label: {
                        Label("Sign in with Apple", image: "apple_icon")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.horizontal)
                        
                    }
                    .padding(.horizontal)
                    .background(.thinMaterial, in: .capsule)
                    .foregroundStyle(.primary)
                    .contentShape(.rect)

                }
                .padding(.horizontal)
                Spacer()
                Text(Bundle.main.versionAndEnvironmentLabel)
                    .font(.b4)
                    .foregroundStyle(.secondary)
                    .frame(alignment: .center)
                    .padding(8)
                    .background(.thinMaterial, in: .capsule)
            }
            .padding(.horizontal)
            .padding(.horizontal)

            ZStack {
                Color.black.opacity(0.1)
                    .ignoresSafeArea(.all)
                VStack {
                    VStack {
                        if let fireblocksLogsURL = fireblocksManager.getURLForLogFiles() {
                            ShareLink(item: fireblocksLogsURL) {
                                Label("Send Logs", image: "sendLogsMenu")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .simultaneousGesture(TapGesture().onEnded() {
                                showMenu = false
                            })
                        }
                        #if DEV || !EW
                        Divider()
                        Button {
                            viewModel.clearWallet()
                            showMenu = false
                        } label: {
                            Label("Clear and create a new wallet", image: "trashMenu")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            
                        }
                        .contentShape(.rect)
                        #endif
                        
                    }
                    .background(.thinMaterial, in: .rect(cornerRadius: 16))
                    .foregroundStyle(.secondary)
                    Spacer()

                }
            }
            .padding()
            .opacity(showMenu ? 1 : 0)
            .animation(.default, value: showMenu)
            .onTapGesture {
                showMenu = false
            }
        }
        .onAppear() {
            viewModel.setup(authRepository: AuthRepository(), loadingManager: loadingManager, coordinator: coordinator, fireblocksManager: fireblocksManager, googleSignInManager: googleSignInManager, appleSignInManager: appleSignInManager)
            if let error {
                loadingManager.setAlertMessage(error: error)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Image("navigationBar")
                    Text(Constants.navigationTitle)
                        .font(.h2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()
                }
                .contentShape(.rect)
                .onTapGesture {
                    showMenu = false
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showMenu.toggle()
                } label: {
                    Image("menuButton")
                }

            }
            
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $viewModel.isShareLogsPresented) {
            if let fireblocksLogsURL = viewModel.fireblocksLogsURL {
                GenericController(uiViewType: UIActivityViewController(activityItems: [ fireblocksLogsURL], applicationActivities: nil))
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            SignInView()
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
                .environmentObject(AppleSignInManager())
                .environmentObject(SignInViewModel.shared)
        }
    }
}
