//
//  WelcomeView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var authRepository: AuthRepository
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager
    @StateObject var viewModel = ViewModel()
    @Binding var showLoader: Bool

    var body: some View {
        ZStack {
            header
            VStack {
                ZStack {
                    Color(.reverse)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    VStack(spacing: 16) {
                        welcome
                        subtitle
                        if viewModel.isMainPresented {
                            VStack(spacing: 16) {
                                VStack {
                                    mainButtons
                                    
                                    Spacer()
                                }
                            }
                        } else {
                            VStack(spacing: 8) {
                                LabeldButton(icon: Image(.googleIcon), title: AuthType.Google.title(loginMethod: viewModel.loginMethod)) {
                                    viewModel.authType = .Google
                                }
                                LabeldButton(icon: Image(.appleIcon), title: AuthType.iCloud.title(loginMethod: viewModel.loginMethod)) {
                                    viewModel.authType = .iCloud
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(24)
                    
                }
                .animation(.default, value: viewModel.isMainPresented)
                .animation(.easeInOut(duration: 1), value: viewModel.offset)

            }
            .offset(y: viewModel.offset)

            if viewModel.isMainPresented {
                VStack(spacing: 16) {
                    Spacer()
                    divider
                    joinButton
                }
                .padding(24)
                .padding(.bottom, 16)
            }

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
        }
        .ignoresSafeArea(.all)
        .addBridge(viewModel.bridge)
    }
}

private extension WelcomeView {
    var header: some View {
        VStack {
            Image(.loginHeader)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .overlay {
                    VStack {
                        Spacer()
                        VStack {
                            Image(.fireblocksLogo)
                            Text(Bundle.main.versionLabel)
                                .font(.body2)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(.reverse).opacity(0.6))
                                .clipShape(.capsule)
                        }
                    }
                    .padding(.bottom, 40)
                }
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    var welcome: some View {
        HStack(spacing: 24) {
            Button(action: {
                viewModel.isMainPresented = true
            }, label: {
                Image(systemName: "arrow.left")
                    .imageScale(.small)
                    .font(.h2)

            })
            .opacity(viewModel.isMainPresented ? 0 : 1)
            Text("Welcome to Bitvault")
                .font(.h1)
            
            Button(action: {
                print("back")
            }, label: {
                Image(systemName: "arrow.left")
                    .imageScale(.small)
                    .font(.h2)
            })
            .opacity(0)

        }
        .foregroundStyle(.primary)
    }
    
    var subtitle: some View {
        Text(viewModel.isMainPresented ? LocalizableStrings.mainViewTitle : viewModel.loginMethod.subtitle())
            .font(.body1)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    var mainButtons: some View {
        HStack {
            LargeButton(icon: Image(.existingAccount), title: "Existing user", subtitle: LocalizableStrings.signInTitle) {
                viewModel.mainButtonTapped(loginMethod: .signIn)
            }
            
            LargeButton(icon: Image(.newAccount), title: "New user", subtitle: LocalizableStrings.signUpTitle) {
                viewModel.mainButtonTapped(loginMethod: .signUp)
            }

        }
    }
    
    var divider: some View {
        HStack {
            VStack {
                Divider()
                    .foregroundStyle(.secondary.opacity(0.2))
            }
            Text("Or")
                .font(.body1)
                .foregroundStyle(.secondary)
            VStack {
                Divider()
                    .foregroundStyle(.secondary.opacity(0.2))
            }
        }
    }
    
    var joinButton: some View {
        Button {
            viewModel.mainButtonTapped(loginMethod: .addDevice)
        } label: {
            Text(LocalizableStrings.addDeviceTitle)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .background(.secondary.opacity(0.2))
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .tint(.primary)

    }
}

#Preview {
    WelcomeView(showLoader: .constant(false))
}
