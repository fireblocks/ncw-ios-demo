//
//  ViewControllerExtensions.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import UIKit
import SwiftUI

extension UIViewController{
    func getMainStoryboard() -> UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: Bundle.main)
    }
    
    func showActivityIndicator(message: String? = nil, isBackgroundEnabled: Bool = true){
        ActivityIndicator.shared.showLoadingIndicator(
            in: self.view,
            message: message,
            isBackgroundEnabled: isBackgroundEnabled
        )
    }
    
    func hideActivityIndicator(){
        ActivityIndicator.shared.hideLoadingIndicator()
    }
    
    func showAlert(
        title: String = "",
        description: String,
        alertType: AlertViewType = AlertViewType.error,
        isAnimationEnabled: Bool = true,
        edgePadding: CGFloat = 16,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil
    ) -> AlertView {
        let alertView = AlertView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        alertView.setMessage(title: title, description: description, alertType: alertType)
        view.addSubview(alertView)
        NSLayoutConstraint.activate([
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgePadding),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgePadding),
            alertView.bottomAnchor.constraint(equalTo: bottomAnchor ?? view.bottomAnchor, constant: -edgePadding)
        ])
        
        if isAnimationEnabled {
            alertView.fadeOut()
        }
        
        return alertView
    }

    func showToast(_ message: String = "", type: ToastViewType? = nil) {
        let customView = ToastView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        if !message.isEmpty {
            customView.setMessage(message)
        }
        
        if let type = type {
            customView.setImage(type: type)
        }
        
        NSLayoutConstraint.activate([
            customView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        customView.fadeOut(duration: 1, delay: 2)
    }
    
    func setNavigationControllerRightButton(icon: AssetsIcons, action: Selector) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: icon.getIcon(),
            style: .plain,
            target: self,
            action: action
        )
        navigationItem.rightBarButtonItem?.tintColor = AssetsColors.white.getColor()
    }
}


extension UIViewController {
    func setBottomBarBackground() {
        // Use the current window from the view's window scene
        guard let windowScene = view.window?.windowScene,
              let window = windowScene.windows.first else {
            return
        }

        let bottomInset = window.safeAreaInsets.bottom

        let homeIndicatorBackgroundView = UIView(frame: CGRect(
            x: 0,
            y: view.bounds.height,
            width: view.bounds.width,
            height: bottomInset
        ))
        homeIndicatorBackgroundView.backgroundColor = AssetsColors.background.getColor() // Customize your color
        homeIndicatorBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(homeIndicatorBackgroundView)

    }
    
    func createLogFile() {
        guard let url = FireblocksManager.shared.getURLForLogFiles() else {
            print("Can't get file log url")
            return
        }
        
        guard let appLogUrl = AppLoggerManager.shared.logger()?.getURLForLogFiles() else {
            print("Can't get app file log url")
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [url as Any, appLogUrl as Any],
            applicationActivities: nil
        )
        
        UIApplication.shared.currentUIWindow()?.rootViewController?
            .present(
                activityVC, animated: true, completion: nil
            )
    }
    
    func addSwiftUIView(rootView: AnyView, container: UIView) -> UIView {
        let vc = UIHostingController(rootView: rootView)
        let swiftuiView = vc.view!
        swiftuiView.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
        container.addSubview(swiftuiView)
        NSLayoutConstraint.activate([
            swiftuiView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            swiftuiView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            swiftuiView.widthAnchor.constraint(equalTo: container.widthAnchor),
            swiftuiView.heightAnchor.constraint(equalTo: container.heightAnchor),
        ])
        vc.didMove(toParent: self)
        return swiftuiView
    }
}
