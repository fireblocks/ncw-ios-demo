//
//  AlertBannerView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import SwiftUI

struct AlertBannerView: View {
    var icon: String = AssetsIcons.error.rawValue
    var message: String?
    var subtitle: String?
    var color: Color = AssetsColors.alert.color()
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(icon)
                VStack {
                    if let message {
                        Text(message)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(AssetsColors.white.color())
                            .bold()
                    }
                    if let subtitle {
                        Text(subtitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(AssetsColors.white.color())
                    }

                }
            }
            .padding()
            .foregroundColor(color)
            .background(color.opacity(0.2), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 1)
            )
        }
    }
}

struct AlertBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AlertBannerView(message: LocalizableStrings.approveJoinWalletCanceled)
            AlertBannerView(subtitle: LocalizableStrings.approveJoinWalletCanceledSubtitle)
            AlertBannerView(message: LocalizableStrings.approveJoinWalletCanceled, subtitle: LocalizableStrings.approveJoinWalletCanceledSubtitle)
            AlertBannerView(message: LocalizableStrings.approveJoinWalletCanceled, subtitle: LocalizableStrings.approveJoinWalletCanceledSubtitle, color: AssetsColors.warning.color())
        }
        .padding()
    }
}
