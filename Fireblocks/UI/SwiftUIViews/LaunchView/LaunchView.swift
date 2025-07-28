//
//  LaunchView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
import UIKit

struct LaunchView: View {
    @EnvironmentObject var viewModel: SignInViewModel
    @EnvironmentObject var coordinator: Coordinator
            
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack {
                VStack(spacing: 0) {
                    Text("Securely store, send, and receive digital assets on the go.")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    Button {
                        coordinator.path.append(NavigationTypes.signIn)
                    } label: {
                        Image("getStarted")
                    }
                    .padding(.vertical, 40)
                }
                .padding(.horizontal)
                Spacer()
                Image(.launchIllustration)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.7)
                Spacer()
                Text(Bundle.main.versionAndEnvironmentLabel)
                    .font(.b4)
                    .foregroundStyle(.secondary)
                    .frame(alignment: .center)
                    .padding(8)
                    .background(.thinMaterial, in: .capsule)
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationBarLeftHeader()
                }
            }
        }
    }
}

#Preview {
    NavigationContainerView {
        LaunchView()
            .environmentObject(SignInViewModel.shared)
    }
}
