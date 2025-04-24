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
    let image: ImageResource
    let mainAction: () -> ()

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 24)
            {
                Image(image)
                VStack {
                    Text(title)
                        .font(.h3)                    
                    Button {
                        mainAction()
                    } label: {
                        Text(mainTitle)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AssetsColors.gray1.color())
                    .contentShape(.rect)
                    .clipShape(.capsule)
                    .padding(.top, Dimens.paddingDefault)
                    Button {
                        dismiss()
                    } label: {
                        Text("Never mind")
                            .font(.b1)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderless)
                    .tint(.secondary)
                    .contentShape(.rect)
                    .clipShape(.capsule)
                    .padding(.top, Dimens.paddingDefault)
                }
                .padding()
            }
            
        }
    }
}

#Preview {
    DiscardAlert(title: "Are you sure you want to sign out?", mainTitle: "Sign out", image: .signOut) {
        print("main")
    }
}
