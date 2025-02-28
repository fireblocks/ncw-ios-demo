//
//  BottomBanner.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 20/02/2025.
//

import SwiftUI

struct BottomBanner: View {
    var text: String?
    var body: some View {
        VStack(spacing: 0) {
            Text(text ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding()
                .background(.thinMaterial, in: .rect(cornerRadius: 8))
                .opacity(text != nil ? 1 : 0)
        }
        .frame(height: text == nil ? 0 : nil)
        .clipped()
    }
}

#Preview {
    VStack {
        BottomBanner(text: "Hello, world")
        BottomBanner()
    }
}
