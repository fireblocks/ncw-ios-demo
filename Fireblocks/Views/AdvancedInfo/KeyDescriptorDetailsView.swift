//
//  KeyDescriptorDetailsView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI
import FireblocksSDK

struct KeyDescriptorDetailsView: View {
    let key: KeyDescriptor
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("Key ID")
                    .font(.body1).bold()
                    .foregroundStyle(.secondary)
                StrokeLabel(text: key.keyStatus.rawValue, color: key.keyStatus == .READY ? .green : .red)
                Spacer()
            }
            
            Text(key.keyId)
                .font(.body2)
                .multilineTextAlignment(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Algoritm")
                    .font(.body1).bold()
                    .foregroundStyle(.secondary)
                Text(key.algorithm.rawValue)
                    .font(.body2)
                    .multilineTextAlignment(.leading)
            }

        }
    }
}

//#Preview {
//    KeyDescriptorDetailsView(key: KeyDescriptor)
//}
