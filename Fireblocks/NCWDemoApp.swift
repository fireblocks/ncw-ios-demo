//
//  NCWDemoApp.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import Foundation
import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct NCWDemoApp: App {
    @StateObject private var appRootManager = AppRootManager()
    @StateObject private var authRepository = AuthRepository()
    @StateObject private var bannerErrorsManager = BannerErrorsManager()
    @State var showLoader = false
    @State var toast: String? {
        didSet {
            if toast != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.toast = nil
                }
            }
        }
    }
    
    @State var noUserPath = NavigationPath()
    @State var addDevicePath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            withAnimation {
                Group {
                    switch appRootManager.currentRoot {
                    case .login:
                        LoaderContainer(showLoader: $showLoader, toast: $toast) {
                            WelcomeView(showLoader: $showLoader)
                        }

                    case .noUser:
                        LoaderContainer(showLoader: $showLoader, toast: $toast) {
                            NavigationContainer(path: $noUserPath, showLoader: $showLoader, toast: $toast) {
                                RedirectNewUserView(path: $noUserPath)
                            }
                        }

                    case .addDevice:
                        LoaderContainer(showLoader: $showLoader, toast: $toast) {
                            NavigationContainer(path: $addDevicePath, showLoader: $showLoader, toast: $toast) {
                                StartJoinDeviceFlowView(showLoader: $showLoader, path: $addDevicePath)
                            }
                        }
                    case .generateKeys:
                        Text("GENERATE KEYS")
                    case .assets:
                        Text("ASSETS")
                    }
                }
            }
            .onAppear() {
                FirebaseApp.configure()
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) // get the Documents folder path
                
                let pathForDocumentDir = documentsPath[0]
                print("pathForDocumentDir: \(pathForDocumentDir)")

            }
            .environmentObject(appRootManager)
            .environmentObject(authRepository)
            .environmentObject(bannerErrorsManager)
        }
    }
}
