//
//  SceneDelegate.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import UIKit
import SwiftUI
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: - FUNCTIONS
    deinit {
        cancellable.removeAll()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let window = (scene as? UIWindowScene) else { return }
//        loadRootViewController(window)
        Task {
            await loadLaunchViewController(window)
        }
        configNavigationBar()
    }
    
    private func loadLaunchViewController(_ windowScene: UIWindowScene) async {
        let window = UIWindow(windowScene: windowScene)
        if let _ = UsersLocalStorageManager.shared.getAuthProvider() {
            if await AuthRepository.getUserIdToken() != nil {
                let viewModel = SignInViewModel()
                viewModel.fireblocksManager = FireblocksManager.shared
                await viewModel.handleSuccessSignIn(isLaunch: true)
            } else {
                let rootViewController = UIHostingController(
                    rootView: NavigationContainerView() {
                        SpinnerViewContainer {
                            SignInView()
                        }
                    }
                )
                window.rootViewController = rootViewController
                self.window = window
                window.makeKeyAndVisible()
            }
        } else {
            let rootViewController = UIHostingController(
                rootView: NavigationContainerView() {
                    let viewModel = LaunchView.ViewModel()
                    LaunchView(viewModel: viewModel)
                }
            )
            window.rootViewController = rootViewController
            self.window = window
            window.makeKeyAndVisible()
        }

    }
    
    private func configNavigationBar() {
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = AssetsIcons.back.getIcon()
        UINavigationBar.appearance().backIndicatorImage = AssetsIcons.back.getIcon()
        UINavigationBar.appearance().tintColor = AssetsColors.white.getColor()
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)

    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
}
