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
    case recoverWallet
    case addDevice
}

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
}

struct NavigationContainerView<Content: View>: View {
    
    @StateObject var coordinator = Coordinator()
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
                    }
                case .joinOrRecover:
                    SpinnerViewContainer {
                        JoinOrRecoverView()
                    }
                case .recoverWallet:
                    SpinnerViewContainer {
                        RecoverWalletView()
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
