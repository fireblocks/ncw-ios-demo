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
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @EnvironmentObject var googleSignInManager: GoogleSignInManager
    @StateObject var viewModel: SettingsViewModel
    
    init(vm: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: vm)
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
                ForEach(viewModel.settingsGeneralActions) { action in
                    settingsRow(data: action)
                }
            }

        }
        .listStyle(.insetGrouped)
        .onAppear() {
            viewModel.setup(coordinator: coordinator)
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .onChange(of: viewModel.isShareLogsPresented) { oldValue, newValue in
            print(newValue)
        }
    }
}

extension SettingsView {
    @ViewBuilder
    func settingsRow(data: SettingsData) -> some View {
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
        .onTapGesture {
            data.action()
        }
        .sheet(isPresented: $viewModel.isShareLogsPresented) {
            if let appLogoURL = viewModel.appLogoURL, let fireblocksLogsURL = viewModel.fireblocksLogsURL {
                GenericController(uiViewType: UIActivityViewController(activityItems: [appLogoURL, fireblocksLogsURL], applicationActivities: nil))
                .presentationDetents([.medium])
            }
        }
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

