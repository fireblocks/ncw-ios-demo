//
//  NavigationContainerView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

enum NavigationTypes: Hashable {
    case signIn
    case joinOrRecover
    case recoverWallet(Bool)
    case addDevice
}

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
}

struct NavigationContainerView<Content: View>: View {
    @StateObject var coordinator = Coordinator()
    @StateObject var fireblocksManager = FireblocksManager.shared
    @StateObject var googleSignInManager = GoogleSignInManager()
    @StateObject var appleSignInManager = AppleSignInManager()
    @ViewBuilder var content: Content
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .environmentObject(coordinator)
            .navigationDestination(for: NavigationTypes.self) { type in
                switch type {
                case .signIn:
                    SpinnerViewContainer {
                        SignInView()
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            .environmentObject(googleSignInManager)
                            .environmentObject(appleSignInManager)
                    }
                case .joinOrRecover:
                    SpinnerViewContainer {
                        JoinOrRecoverView()
                            .environmentObject(coordinator)
                    }
                case .recoverWallet(let redirect):
                    SpinnerViewContainer {
                        RecoverWalletView(redirect: redirect)
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            .environmentObject(googleSignInManager)
                    }
                case .addDevice:
                    SpinnerViewContainer {
                        AddDeviceView()
                    }

                }
            }
        }
    }
}

#Preview {
    NavigationContainerView() {
        Text("Hello")
    }
}
