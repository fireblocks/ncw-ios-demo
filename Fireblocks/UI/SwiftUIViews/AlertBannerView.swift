//
//  AlertBannerView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import SwiftUI

struct AlertBannerView: View {
    var icon: String = AssetsIcons.error.rawValue
    let message: String?
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(icon)
                Text(message ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(AssetsColors.white.color())
            }
            .padding()
            .foregroundColor(AssetsColors.alert.color())
            .background(AssetsColors.alert.color().opacity(0.2), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AssetsColors.alert.color(), lineWidth: 1)
            )
        }
        .padding()

    }
}

struct AlertBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AlertBannerView(message: "\(LocalizableStrings.approveJoinWalletCanceled)\n\(LocalizableStrings.approveJoinWalletCanceledSubtitle)")
    }
}
