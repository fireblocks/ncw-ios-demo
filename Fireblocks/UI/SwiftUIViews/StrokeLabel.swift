//
//  StrokeLabel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct StrokeLabel: View {
    let text: String
    let color: Color
    var font: SwiftUI.Font = .body3
    var body: some View {
        Text(text.capitalized)
            .font(font).bold()
            .foregroundStyle(color)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
            }
    }
}

#Preview {
    StrokeLabel(text: "HELLO world", color: .green)
}
