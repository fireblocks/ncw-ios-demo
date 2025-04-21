//
//  GenericController.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 11/02/2025.
//

import UIKit
import SwiftUI

struct GenericControllerNoEnvironments<T: UIViewController>: UIViewControllerRepresentable, Hashable {

    static func == (lhs: GenericControllerNoEnvironments<T>, rhs: GenericControllerNoEnvironments<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String = UUID().uuidString
    let uiViewType: T
    var configuration: ((T) -> ())? = nil
    func makeUIViewController(context: Context) -> UIViewController {
        return uiViewType
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        configuration?(uiViewController as! T)

    }

}

struct GenericController<T: UIViewController>: UIViewControllerRepresentable, Hashable {
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var coordinator: Coordinator
    #if EW
    @Environment(EWManager.self) var ewManager
    #endif

    static func == (lhs: GenericController<T>, rhs: GenericController<T>) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String = UUID().uuidString
    let uiViewType: T
    var configuration: ((T) -> ())? = nil
    func makeUIViewController(context: Context) -> UIViewController {
        if uiViewType is SwiftUIEnvironmentBridge {
            #if EW
            (uiViewType as! SwiftUIEnvironmentBridge).setEnvironment(loadingManager: loadingManager, coordinator: coordinator, ewManager: ewManager)
            #else
            (uiViewType as! SwiftUIEnvironmentBridge).setEnvironment(loadingManager: loadingManager, coordinator: coordinator)
            #endif
        }

        return uiViewType
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        configuration?(uiViewController as! T)

    }

}
