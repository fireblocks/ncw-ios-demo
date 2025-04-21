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
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
                            FirebaseApp.configure()
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

//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//        FirebaseApp.configure()
//        return true
//    }
//    
//    // MARK: UISceneSession Lifecycle
//    
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//    
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
//    
//}

