//
//  BridgeVC.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import Foundation
import SwiftUI

struct BridgeVCView: UIViewControllerRepresentable {
    let vc = UIViewController()
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //
    }
}

extension View {
    func addBridge(_ bridge: BridgeVCView) -> some View {
        self.background(bridge.frame(width: 0, height: 0))
    }
    
    func toast(message: String?) -> some View {
        withAnimation {
            self.overlay {
                if let message {
                    Text(message)
                        .font(.body1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color(.reverse))
                        .clipShape(.capsule)
                        .overlay(
                            Capsule()
                                .stroke(.primary, lineWidth: 1)
                        )
                }
            }
        }
    }
}
