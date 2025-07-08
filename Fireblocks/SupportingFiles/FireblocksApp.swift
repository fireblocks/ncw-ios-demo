//
//  AppDelegate.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct FireblocksApp: App {
    #if EW
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @StateObject var viewModel = SignInViewModel.shared
    @State var launchView: (any View)?
    @State var didLaunch = false

    func computedView() async {
        if let _ = UsersLocalStorageManager.shared.getAuthProvider() {
            if await AuthRepository.getUserIdToken() != nil {
                viewModel.fireblocksManager = FireblocksManager.shared
                await viewModel.handleSuccessSignIn(isLaunch: true)
            } else {
                viewModel.launchView = NavigationContainerView {
                    SpinnerViewContainer {
                        SignInView()
                            .environmentObject(viewModel)
                    }
                }
            }
        } else {
            launchView = NavigationContainerView {
                LaunchView()
                    .environmentObject(viewModel)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if let launchView = viewModel.launchView {
                AnyView(launchView)
                    .environmentObject(viewModel)
                    .task {
                        await MainActor.run {
                            if self.launchView != nil {
                                self.launchView = nil
                            }
                        }
                    }
            } else if let launchView = self.launchView {
                AnyView(launchView)
                    .environmentObject(viewModel)
            } else {
                AppBackgroundView()
                    .onAppear() {
                        configNavigationBar()
                        if !didLaunch {
                            didLaunch = true
                            #if !EW
                            FirebaseApp.configure()
                            #endif
                        }
                    }
                    .task {
                        await computedView()
                    }
            }
        }
    }
    
    private func configNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AssetsColors.background.getColor() // Setting the desired background color

        // Remove the bottom divider
        appearance.shadowColor = .clear
                
        // Keeping the existing icon and tint customizations
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = AssetsIcons.back.getIcon()
        UINavigationBar.appearance().backIndicatorImage = AssetsIcons.back.getIcon()
        UINavigationBar.appearance().tintColor = AssetsColors.white.getColor()
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        UINavigationBar.appearance().isTranslucent = false
        
        appearance.backgroundColor = AssetsColors.background.getColor()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        

    }

}



