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
    
    static var h3: SwiftUI.Font {
        return .custom(FontStyleType.h3.fontName, size: FontStyleType.h3.size)
    }
    
    static var h4: SwiftUI.Font {
        return .custom(FontStyleType.h4.fontName, size: FontStyleType.h4.size)
    }
    
    static var b1: SwiftUI.Font {
        return .custom(FontStyleType.b1.fontName, size: FontStyleType.b1.size)
    }
    
    static var b2: SwiftUI.Font {
        return .custom(FontStyleType.b2.fontName, size: FontStyleType.b2.size)
    }
    
    static var b3: SwiftUI.Font {
        return .custom(FontStyleType.b3.fontName, size: FontStyleType.b3.size)
    }

    static var b4: SwiftUI.Font {
        return .custom(FontStyleType.b4.fontName, size: FontStyleType.b4.size)
    }

}

