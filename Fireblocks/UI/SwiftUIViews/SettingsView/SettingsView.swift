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
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @EnvironmentObject var googleSignInManager: GoogleSignInManager
    @State var viewModel: SettingsViewModel
    
    init(vm: SettingsViewModel = SettingsViewModel()) {
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
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
                }
            } header: {
                EmptyView()
            } footer: {
                EmptyView()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.bottom, 24)
            
            Section("Wallet Actions") {
                ForEach(viewModel.settingsWalletActions) { action in
                    settingsRow(data: action)
                }
            }
            
            Section("General Settings") {
                if let advanceInfoAction = viewModel.advanceInfoAction {
                    settingsRow(data: advanceInfoAction)
                }
                if !viewModel.items.isEmpty {
                    ShareLink(items: viewModel.items) {
                        settingsInnerRow(data: SettingsData(icon: "settingsShareLogs", title: "Share logs", subtitle: nil, action: nil))
                            .foregroundStyle(.white)
                    }
                }
                if let signOutAction = viewModel.signOutAction {
                    settingsRow(data: signOutAction)
                }

            }

        }
        .listStyle(.insetGrouped)
        .onAppear() {
            viewModel.setup(coordinator: coordinator)
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .sheet(isPresented: $viewModel.isDiscardAlertPresented) {
            DiscardAlert(title: "Are you sure you want to sign out?", mainTitle: "Sign out") {
                viewModel.isDiscardAlertPresented = false
                viewModel.signOutFromFirebase()
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
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
        .padding(.vertical)
        .contentShape(.rect)
    }

}

#Preview {
    NavigationContainerView {
        SettingsView(vm: SettingsViewModelMock())
            .environmentObject(FireblocksManager.shared)
            .environmentObject(GoogleSignInManager())
            .environmentObject(AppleSignInManager())
    }
}

