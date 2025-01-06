//
//  LaunchView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
import UIKit

struct LaunchView: View {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject var coordinator: Coordinator
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
        
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack {
                VStack(spacing: 40) {
                    Spacer()
                    Text("Securely store, send, and receive digital assets on the go.")
                        .font(.h1)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    Button {
                        coordinator.path.append(NavigationTypes.signIn)
                    } label: {
                        Image("letsGo")
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxHeight: .infinity)
                VStack {
                    Image(.launchIllustration)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(0.7)
                    Spacer()
                    Text(Bundle.main.versionLabel)
                        .font(.b4)
                        .foregroundStyle(.secondary)
                        .frame(alignment: .center)
                        .padding(8)
                        .background(.thinMaterial, in: .capsule)
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Image("navigationBar")
                        Text(Constants.navigationTitle)
                            .font(.h2)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationContainerView {
        LaunchView(viewModel: LaunchView.ViewModel())
    }
}
