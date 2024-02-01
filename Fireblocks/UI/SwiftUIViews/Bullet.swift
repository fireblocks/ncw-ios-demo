//
//  Bullet.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 01/02/2024.
//

import Foundation
import SwiftUI

struct Bullet: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subtitle3)
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AssetsColors.gray1.color())
            .cornerRadius(4)
    }
}

