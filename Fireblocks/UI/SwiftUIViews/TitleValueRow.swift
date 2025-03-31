//
//  TitleValueRow.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import SwiftUI

struct TitleValueRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.b2)
    }
}

#Preview {
    TitleValueRow(title: "Title", value: "Value")
}
