//
//  LabeldButton.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import SwiftUI

struct LabeldButton: View {
    var icon: Image?
    var title: String?
    var action: (() -> ())?
    var body: some View {
        Button(action: {
            action?()
        }, label: {
            HStack {
                Spacer()
                if let icon {
                    icon
                }
                if let title {
                    Text(title)
                        .font(.body1)
                }
                Spacer()
            }
            .padding(16)
        })
        .tint(.primary)
        .contentShape(Rectangle())
        .background(.secondary.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack {
        LabeldButton(icon: Image(.googleIcon), title: LocalizableStrings.loginGoogleSignIn) {
            print("google")
        }
    }
}
