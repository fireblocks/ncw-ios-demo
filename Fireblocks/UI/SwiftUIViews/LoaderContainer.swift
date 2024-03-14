//
//  LoaderContainer.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import SwiftUI

struct LoaderContainer<Content: View>: View {
    @Binding var showLoader: Bool
    @Binding var toast: String?

    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            content
            
            ZStack {
                Color.secondary.opacity(0.7)
                    .ignoresSafeArea()
                Spinner()
            }
            .opacity(showLoader ? 1 : 0)

            if let toast {
                Text(toast)
                    .font(.body1)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule()
                            .stroke(.secondary, lineWidth: 1)
                    )
            }

        }
        .animation(.default, value: showLoader)
    }
}

#Preview {
//    LoaderContainer(showLoader: .constant(false), toast: .constant("copied")) {
//        Color.green
//    }
    LoaderContainer(showLoader: .constant(false), toast: .constant(nil)) {
        ZStack {
            Color.green
        }
        .toast(message: "ffff")
    }
}
