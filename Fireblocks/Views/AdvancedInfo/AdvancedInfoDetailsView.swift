//
//  AdvancedInfoDetailsView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct AdvancedInfoDetailsView: View {
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager
    let header: String
    let details: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(header)
                    .font(.body1).bold()
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    bannerErrorsManager.toastMessage = ToastItem(icon: AssetsIcons.checkMark.rawValue, message: "copied")
                    UIPasteboard.general.string = details
                } label: {
                    Image(uiImage: AssetsIcons.copy.getIcon())
                }
                .tint(.primary)
            }
            
            Text(details)
                .frame(alignment: .leading)
                .font(.body1).bold()
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

        }
    }
}

#Preview {
    AdvancedInfoDetailsView(header: "Wallet ID", details: "abcdkhsdkjkjksdskksdkjksdksdkskdjkkskskabcdkhsdkjkjksdskksdkjksdksdkskdjkksksk")
}
