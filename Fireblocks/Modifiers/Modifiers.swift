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
    case subtitle1
    case subtitle2
    case subtitle3
    case body1
    case body2
    case body3
    case body4
    case body5
    case custom(fontName: String, size: CGFloat, lineSpacing: CGFloat = 0)
    
    var fontName: String {
        switch self {
        case .h1, .h2, .subtitle1, .subtitle2, .subtitle3:
            return AppFonts.defaultBold
        case .body1, .body2, .body3, .body4, .body5:
            return AppFonts.defaultRegular
        case .custom(fontName: let fontName, _, _):
            return fontName
        }
    }
    
    var size: CGFloat {
        switch self {
        case .h1:
            return 24
        case .h2:
            return 20
        case .subtitle1:
            return 16
        case .subtitle2:
            return 14
        case .subtitle3:
            return 12
        case .body1:
            return 16
        case .body2:
            return 14
        case .body3:
            return 12
        case .body4:
            return 20
        case .body5:
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
            .foregroundStyle(Color(.reverse))
    }
}

struct H2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.h2)
            .lineSpacing(8)
            .padding(.vertical, 4)
            .foregroundStyle(Color(.reverse))

    }
}

struct Subtitle1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subtitle1)
            .lineSpacing(10)
            .padding(.vertical, 5)
            .foregroundStyle(Color(.reverse))

    }
}

struct Subtitle2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subtitle2)
            .lineSpacing(6)
            .padding(.vertical, 3)
            .foregroundStyle(Color(.reverse))

    }
}

struct Subtitle3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subtitle3)
            .lineSpacing(6)
            .padding(.vertical, 3)
            .foregroundStyle(Color(.reverse))

    }
}

struct Body1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body1)
            .lineSpacing(10)
            .padding(.vertical, 5)
            .foregroundStyle(Color(.reverse))

    }
}

struct Body2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body2)
            .lineSpacing(6)
            .padding(.vertical, 3)
            .foregroundStyle(Color(.reverse))

    }
}

struct Body3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body3)
            .foregroundStyle(Color(.reverse))
    }
}
