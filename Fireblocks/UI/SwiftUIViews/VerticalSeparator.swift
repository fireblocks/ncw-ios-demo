//
//  VerticalSeparator.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 01/02/2024.
//

import Foundation
import SwiftUI

struct VerticalSeparator: View {
    var body: some View {
        HStack {
            HStack {}
                .frame(width: 4, height: 32)
                .background(AssetsColors.gray1.color())
                .cornerRadius(4)
                .padding(.horizontal, 11)
            Spacer()
        }
    }
}

