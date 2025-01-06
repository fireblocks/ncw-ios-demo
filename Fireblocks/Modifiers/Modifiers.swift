//
//  Modifiers.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import Foundation
import UIKit
import SwiftUI

struct AppFonts {
    static let defaultRegular = "Roboto-Regular"
    static let defaultMedium = "Roboto-Bold"
    static let defaultBold = "Roboto-Bold"
}

enum FontStyleType: Equatable {
    case h1
    case h2
    case h3
    case h4
    case b1
    case b2
    case b3
    case b4
    case custom(fontName: String, size: CGFloat, lineSpacing: CGFloat = 0)
    
    var fontName: String {
        switch self {
        case .h1, .h2, .h3, .h4:
            return AppFonts.defaultBold
        case .b1, .b2, .b3, .b4:
            return AppFonts.defaultRegular
        case .custom(fontName: let fontName, _, _):
            return fontName
        }
    }
    
    var size: CGFloat {
        switch self {
        case .h1:
            return 32
        case .h2:
            return 24
        case .h3:
            return 20
        case .h4:
            return 16
        case .b1:
            return 16
        case .b2:
            return 14
        case .b3:
            return 12
        case .b4:
            return 10
        case .custom(_, size: let size, _):
            return size
        }
    }
    
    var font: UIFont {
        return textStyle.font()
    }
    
    var textStyle: Style.TextStyle {
        return Style.TextStyle(fontName: self.fontName, fontSize: self.size)
    }
}


struct H1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.h1)
            .lineSpacing(10)
            .padding(.vertical, 5)
    }
}

struct H2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.h2)
            .lineSpacing(8)
            .padding(.vertical, 4)

    }
}

struct H3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.h3)
            .lineSpacing(8)
            .padding(.vertical, 4)

    }
}

struct H4: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.h4)
            .lineSpacing(8)
            .padding(.vertical, 4)

    }
}



struct B1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.b1)
            .lineSpacing(10)
            .padding(.vertical, 5)

    }
}

struct B2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.b2)
            .lineSpacing(6)
            .padding(.vertical, 3)

    }
}

struct B3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.b3)
    }
}

struct B4: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.b4)
    }
}

