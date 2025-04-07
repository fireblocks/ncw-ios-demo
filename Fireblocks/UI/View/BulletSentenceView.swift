//
//  BulletSentenceView.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI

struct BulletSentenceView: View {
    var textList: [String?]
    var textStyle: Font = .b2

    var body: some View {
        HStack(spacing: 4) {
            ForEach(textList.compactMap { $0 }, id: \.self) { text in
                Text(text)
                    .font(textStyle)
                    .foregroundStyle(.secondary)
                if text != textList.compactMap({ $0 }).last {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 4, height: 4)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct BulletSentence_Previews: PreviewProvider {
    static var previews: some View {
        BulletSentenceView(textList: ["Ethereum", "ERC721"])
    }
}
