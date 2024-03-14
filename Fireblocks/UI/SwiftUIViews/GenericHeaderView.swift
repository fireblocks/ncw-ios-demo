//
//  GenericHeaderView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct GenericHeaderView: View {
    var icon: String?
    var title: String?
    var subtitle: String?
    
    var body: some View {
        VStack(spacing: 0) {
            if let icon {
                Image(icon)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
            }
            
            if let title {
                Text(title)
                    .font(.h2)
                    .padding(.bottom, 24)
            }
            
            if let subtitle {
                Text(subtitle)
                    .font(.body1)
                    .multilineTextAlignment(.center)
            }

        }
    }
}

#Preview {
    GenericHeaderView(icon: AssetsIcons.keyImage.rawValue, title: LocalizableStrings.createKeyBackup, subtitle: LocalizableStrings.backupExplanation)
}
