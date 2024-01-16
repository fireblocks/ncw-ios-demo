//
//  AlertBannerView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import SwiftUI

struct AlertBannerView: View {
    var icon: String = AssetsIcons.error.rawValue
    let message: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(icon)
            Text(message)
                .multilineTextAlignment(.leading)
                .foregroundColor(AssetsColors.white.color())
            Spacer()
        }
        .foregroundColor(AssetsColors.alert.color())
        .padding(16)
        .background(AssetsColors.alert.color().opacity(0.2))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AssetsColors.alert.color(), lineWidth: 1)
        )

    }
}

struct AlertBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AlertBannerView(message: "\(LocalizableStrings.approveJoinWalletCanceled)\n\(LocalizableStrings.approveJoinWalletCanceledSubtitle)")
    }
}
