//
//  GenericController.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 11/02/2025.
//

import UIKit
import SwiftUI

struct GenericController<T: UIViewController>: UIViewControllerRepresentable {
    let uiViewType: T
    var configuration: ((T) -> ())? = nil
    func makeUIViewController(context: Context) -> UIViewController {
        return uiViewType
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        configuration?(uiViewController as! T)

    }

}
