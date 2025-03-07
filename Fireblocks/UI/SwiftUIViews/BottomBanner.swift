//
//  BottomBanner.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 20/02/2025.
//

import SwiftUI

struct BottomBanner: View {
    var message: String?
    var body: some View {
        HStack {
            Text(message ?? "")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .foregroundColor(AssetsColors.white.color())
                .background(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AssetsColors.white.color(), lineWidth: 1)
                )

        }
        .background(Color.clear)
    }
}

#Preview {
    VStack {
        BottomBanner(message: "Hello, world")
    }
}
