//
//  RedirectNewUserView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 25/01/2024.
//

import SwiftUI

struct RedirectNewUserView: View {
    @EnvironmentObject var appRootManager: AppRootManager
    
    @StateObject var viewModel = ViewModel()
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image(AssetsIcons.addDeviceImage.rawValue)
                    .padding(.top, 12)
                    .padding(.bottom, 42)
                
                Text("You can add this device to your existing wallet or recover your existing wallet on this device.")
                    .font(.body4)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 74)
                
                Button {
                    viewModel.addDeviceTapped()
                } label: {
                    HStack {
                        Spacer()
                        Image(AssetsIcons.scanQrCode.rawValue)
                        Text("Add device from sign-in screen")
                            .font(.body1)
                        Spacer()
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
                .tint(.primary)
                .frame(maxWidth: .infinity)
                .background(.secondary.opacity(0.2))
                .cornerRadius(16)
                
                HStack {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.secondary)
                    Text("or")
                        .font(.body1)
                        .foregroundColor(.secondary)
                        .padding(16)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.secondary)
                    
                }
                
                Button {
                    path.append(NavigationTypes.Recover)
                } label: {
                    HStack {
                        Spacer()
                        Image(AssetsIcons.scanQrCode.rawValue)
                        Text("Recover wallet")
                            .font(.body1)
                        Spacer()
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
                .tint(.primary)
                .frame(maxWidth: .infinity)
                .background(.secondary.opacity(0.2))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding(16)
            
        }
        .onAppear() {
            viewModel.setup(appRootManager: appRootManager)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.signOut()
                } label: {
                    Image(AssetsIcons.close.rawValue)
                }
                .tint(.primary)
            }
        }
        .navigationTitle("Add your keys to this device")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()
    }
}

struct RedirectNewUserView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RedirectNewUserView(viewModel: RedirectNewUserView.ViewModel(), path: .constant(NavigationPath()))
        }
    }
}
