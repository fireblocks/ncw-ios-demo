//
//  SettingsView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 10/02/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @EnvironmentObject var googleSignInManager: GoogleSignInManager
    @State var viewModel: SettingsViewModel
    
    init(vm: SettingsViewModel = SettingsViewModel()) {
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            List {
                Section {
                    VStack(spacing: 8) {
                        AsyncImage(url: viewModel.getUrlOfProfilePicture()) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "person")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundStyle(.secondary)
                            @unknown default:
                                EmptyView()
                                
                            }
                        }
                        .frame(width: 88, height: 88)
                        .clipShape(.rect(cornerRadius: 16))
                        .padding(.bottom, 8)
                        Text(viewModel.getUserName())
                            .font(.h2)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text(viewModel.getUserEmail())
                            .font(.b2)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(.secondary)
                        Text(Bundle.main.versionAndEnvironmentLabel)
                            .font(.b4)
                            .foregroundStyle(.secondary)
                            .frame(alignment: .center)
                            .padding(8)
                            .background(.thinMaterial, in: .capsule)
                        Text(Bundle.main.getSDKVersionsLabel())
                            .font(.b4)
                            .foregroundStyle(.secondary)
                            .frame(alignment: .center)
                            .padding(8)
                            .background(.thinMaterial, in: .capsule)
                        
                    }
                } header: {
                    EmptyView()
                } footer: {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                Section() {
                    ForEach(viewModel.settingsWalletActions) { action in
                        settingsRow(data: action)
                    }
                } header: {
                    Text("Actions")
                        .font(.b2)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
                
                Section() {
                    if let advanceInfoAction = viewModel.advanceInfoAction {
                        settingsRow(data: advanceInfoAction)
                    }
                    if !viewModel.items.isEmpty {
                        ShareLink(items: viewModel.items) {
                            settingsInnerRow(data: SettingsData(icon: "settingsShareLogs", title: "Share logs", subtitle: nil, action: nil))
                                .foregroundStyle(.white)
                        }
                    }
                } header: {
                    Text("Advanced")
                        .font(.b2)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
                
                Section() {
                    if let signOutAction = viewModel.signOutAction {
                        settingsRow(data: signOutAction)
                    }
                }
                
            }
            .listRowSeparator(.hidden)
            .listStyle(.insetGrouped)
            .onAppear() {
                viewModel.setup(coordinator: coordinator, loadingManager: loadingManager)
            }
            .navigationBarBackButtonHidden()
            .navigationBarItems(leading: CustomBackButtonView())
            .sheet(isPresented: $viewModel.isDiscardAlertPresented) {
                DiscardAlert(title: "Are you sure you want to sign out?", mainTitle: "Sign out", image: .signOut) {
                    viewModel.isDiscardAlertPresented = false
                    viewModel.signOutFromFirebase()
                }
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

extension SettingsView {
    @ViewBuilder
    func settingsRow(data: SettingsData) -> some View {
        settingsInnerRow(data: data)
        .onTapGesture {
            data.action?()
        }
        .padding()
        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return 0
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    func settingsInnerRow(data: SettingsData) -> some View {
        HStack(spacing: 12) {
            Image(data.icon)
            VStack {
                Text(data.title)
                    .font(.b1)
                if let subtitle = data.subtitle {
                    Text(subtitle)
                        .font(.b3)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .foregroundStyle(.secondary)

        }
        .contentShape(.rect)
    }

}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            SettingsView(vm: SettingsViewModelMock())
                .environmentObject(FireblocksManager.shared)
                .environmentObject(GoogleSignInManager())
                .environmentObject(AppleSignInManager())
        }
    }
}

