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
    
    func toast(item: ToastItem?) -> some View {
        withAnimation {
            self.overlay {
                HStack(spacing: 8) {
                    if let icon = item?.icon {
                        Image(icon)
                            .font(.body1).bold()
                    }
                    if let message = item?.message {
                        Text(message)
                            .font(.body1).bold()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.reverse))
                .clipShape(.capsule)
                .overlay {
                    Capsule()
                        .stroke(.primary, lineWidth: 1)
                }
                .opacity(item != nil ? 1 : 0)

            }
        }
    }
}
