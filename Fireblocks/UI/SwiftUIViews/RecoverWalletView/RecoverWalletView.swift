//
//  RecoverWalletView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

struct RecoverWalletView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack {
                Image(.recoverWallet)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                VStack {
                    Text("Recover Wallet")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                    Text("Recover keys from where you last saved them.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .font(.b1)
                        .padding(.bottom, 56)
                    
                    Button {
                        print("apple")
                    } label: {
                        Label("Recover from Drive", image: "google_icon")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .padding(.horizontal)
                        
                    }
                    .background(.thinMaterial, in: .capsule)
                    .foregroundStyle(.primary)
                    .contentShape(.rect)
                    
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
        RecoverWalletView()
    }
}
