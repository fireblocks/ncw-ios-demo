//
//  LargeButton.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import SwiftUI

struct LargeButton: View {
    var icon: Image?
    var title: String?
    var subtitle: String?
    var action: (() -> ())?
    var body: some View {
        Button(action: {
            action?()
        }, label: {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 12) {
                    if let icon {
                        icon
                    }
                    if let title {
                        Text(title)
                            .font(.body1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.body5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.center)
                        
                    }
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 16)
            }
        })
        .tint(.primary)
        .background(.secondary.opacity(0.2))
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 12))

        
    }
}

#Preview {
    VStack() {
        HStack(spacing: 16) {
            LargeButton(icon: Image(.existingAccount), title: "Existing User", subtitle: "Sign in to your existing wallet", action: {
                print("tapped")
            })
            
            LargeButton(icon: Image(.existingAccount), title: "Existing User", subtitle: "Sign in to your existing wallet", action: {
                print("tapped")
            })

        }
    }
}
