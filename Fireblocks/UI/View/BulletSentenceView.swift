//
//  BulletSentenceView.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 07/04/2025.
//

import SwiftUI

struct BulletSentenceView: View {
    let textList: [String?]
    let textStyle: Font = .b2
    let textColor: Color = .secondary

    var body: some View {
        Text(buildBulletSentence())
            .font(textStyle)
            .foregroundColor(textColor)
    }

    private func buildBulletSentence() -> AttributedString {
        var result = AttributedString()
        let bullet = "•" // Bullet symbol

        for (index, text) in textList.compactMap({ $0 }).enumerated() {
            if index > 0 {
                result.append(AttributedString(" \(bullet) "))
            }
            var attributedText = AttributedString(text)
            attributedText.foregroundColor = textColor
            result.append(attributedText)
        }

        return result
    }
}

#Preview {
    BulletSentenceView(textList: ["Ethereum", "ERC721"])    
}
