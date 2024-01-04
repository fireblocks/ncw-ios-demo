//
//  FBFont.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import Foundation
import SwiftUI

extension UIFont {
    var swiftUI: SwiftUI.Font {
        return SwiftUI.Font(self)
    }
}

extension UIColor  {
    var swiftUI: Color {
        return Color(self)
    }
}

extension SwiftUI.Font {
    
    static var h1: SwiftUI.Font {
        return .custom(FontStyleType.h1.fontName, size: FontStyleType.h1.size)
    }
    
    static var h2: SwiftUI.Font {
        return .custom(FontStyleType.h2.fontName, size: FontStyleType.h2.size)
    }
    
    static var subtitle1: SwiftUI.Font {
        return .custom(FontStyleType.subtitle1.fontName, size: FontStyleType.subtitle1.size)
    }
    
    static var subtitle2: SwiftUI.Font {
        return .custom(FontStyleType.subtitle2.fontName, size: FontStyleType.subtitle2.size)
    }
    
    static var subtitle3: SwiftUI.Font {
        return .custom(FontStyleType.subtitle3.fontName, size: FontStyleType.subtitle3.size)
    }
    
    static var body1: SwiftUI.Font {
        return .custom(FontStyleType.body1.fontName, size: FontStyleType.body1.size)
    }
    
    static var body2: SwiftUI.Font {
        return .custom(FontStyleType.body2.fontName, size: FontStyleType.body2.size)
    }
    
    static var body3: SwiftUI.Font {
        return .custom(FontStyleType.body3.fontName, size: FontStyleType.body3.size)
    }
}

