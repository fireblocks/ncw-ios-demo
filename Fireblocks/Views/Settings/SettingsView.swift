//
//  SettingsView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = ViewModel()
    @Binding var path: NavigationPath
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                AsyncImage(url: viewModel.getUrlOfProfilePicture()) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                    case .failure(_):
                        Image(.error)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        EmptyView()

                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(.circle)
                .padding(.bottom, 8)
                Text(viewModel.getUserName())
                    .font(.h1)
                Text(viewModel.getUserEmail())
                    .font(.body2)
                    .foregroundStyle(.secondary)
                
                Text(Bundle.main.versionLabel)
                    .font(.body2)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.secondary.opacity(0.2))
                    .clipShape(.capsule)
                
                HStack {
                    LargeButton(icon: Image(.backup), title: LocalizableStrings.createABackup) {
                        path.append(NavigationTypes.Backup(false))
                    }
                    
                    LargeButton(icon: Image(.recover), title: LocalizableStrings.recoverWallet) {
                        path.append(NavigationTypes.Recover(false))
                    }
                }
                .padding(.top, 32)

                HStack {
                    LargeButton(icon: Image(.key), title: LocalizableStrings.exportPrivateKey) {
                        path.append(NavigationTypes.Backup(false))
                    }
                    
                    LargeButton(icon: Image(.info), title: LocalizableStrings.advancedInfo) {
                        path.append(NavigationTypes.AdvancedInfo)
                    }
                }

                HStack {
                    LargeButton(icon: Image(.addNewDevice), title: LocalizableStrings.addNewDevice) {
                        path.append(NavigationTypes.AddDevice)
                    }
                    
                    LargeButton(icon: Image(.shareLogs), title: LocalizableStrings.shareLogs) {
                        path.append(NavigationTypes.Recover(false))
                    }
                }

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button {
                        path.removeLast()
                    } label: {
                        Image(uiImage: AssetsIcons.close.getIcon())
                    }
                    .tint(.primary)
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    SettingsView(path: .constant(NavigationPath()))
}
