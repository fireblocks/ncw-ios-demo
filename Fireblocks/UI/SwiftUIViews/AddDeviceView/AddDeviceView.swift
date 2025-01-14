//
//  AddDeviceView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

struct AddDeviceView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack {
                Image(.addDevice)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                VStack {
                    Text("Add device")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                    Text("To keep your assets safe, this device must be added to your wallet.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 56)
                    
                    Button {
                        viewModel.requestJoinWallet()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.horizontal)
                        
                    }
                    .background(.thinMaterial, in: .capsule)
                    .foregroundStyle(.primary)
                    .contentShape(.rect)
                    .padding(.bottom, 16)

                    Text("Make sure you have your previous device nearby before proceeding.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b3)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator, fireblocksManager: fireblocksManager)
        }
    }
}

#Preview {
    NavigationContainerView {
        AddDeviceView()
    }
}
