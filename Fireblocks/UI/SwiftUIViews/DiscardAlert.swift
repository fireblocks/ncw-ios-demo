//
//  DiscardAlert.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 08/03/2025.
//

import SwiftUI

struct DiscardAlert: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let mainTitle: String
    var mainColor: Color = AssetsColors.alert.color()
    let mainAction: () -> ()

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 24) {
                Image(.cancelTransaction)
                    .padding()
                VStack {
                    Text(title)
                    
                    Button {
                        mainAction()
                    } label: {
                        Text(mainTitle)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AssetsColors.alert.color())
                    .contentShape(.rect)
                    .clipShape(.capsule)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Never mind")
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderless)
                    .tint(.secondary)
                    .contentShape(.rect)
                    .clipShape(.capsule)
                }
                .padding()
            }
            
        }
    }
}

#Preview {
    DiscardAlert(title: "Are you sure you want to sign out?", mainTitle: "Sign out") {
        print("main")
    }
}
