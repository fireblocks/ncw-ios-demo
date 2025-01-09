//
//  JoinOrRecoverView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

struct JoinOrRecoverView: View {
    
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack {
                Image("joinOrRecover")
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                VStack {
                    Text("Join or recover?")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                    Text("Add this device to your existing wallet or recover your wallet with this device.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 56)

                    VStack(spacing: 24) {
                        Button {
                            coordinator.path.append(NavigationTypes.addDevice)
                        } label: {
                            Text("Join existing wallet")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .padding(.horizontal)
                            
                        }
                        .background(.thinMaterial, in: .capsule)
                        .foregroundStyle(.primary)
                        .contentShape(.rect)
                        
                        Text("Or")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .font(.b2)

                        Button {
                            coordinator.path.append(NavigationTypes.recoverWallet(true))
                        } label: {
                            Text("Recover this wallet")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .padding(.horizontal)
                            
                        }
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
        .navigationBarItems(leading: CustomBackButtonView())
    }
}

#Preview {
    NavigationContainerView {
        JoinOrRecoverView()
    }
}
