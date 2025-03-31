//
//  Style.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import UIKit

struct Style {
    struct FontName {
        static let medium = "Figtree-Medium"
        static let regular = "Figtree-Regular"
        static let bold = "Figtree-Bold"
    }

    struct TextStyle {
        let fontName: String
        let fontSize: CGFloat
        var textColor: UIColor = .white
        var textAlignment: NSTextAlignment = .natural
        var characterSpacing: CGFloat = 0
        var lineSpacing: CGFloat = 0
        var multiline: Bool = false
        
        init(fontName: String, fontSize: CGFloat, textColor: UIColor = .white, textAlignment: NSTextAlignment = .natural, characterSpacing: CGFloat = 0, lineSpacing: CGFloat = 0, multiline: Bool = false) {
            self.fontName = fontName
            self.fontSize = fontSize
            self.textColor = textColor
            self.textAlignment = textAlignment
            self.characterSpacing = characterSpacing
            self.lineSpacing = lineSpacing
            self.multiline = multiline
        }
        
        init(textStyle: TextStyle, textColor: UIColor = .white, textAlignment: NSTextAlignment = .natural, characterSpacing: CGFloat = 0, lineSpacing: CGFloat = 0, multiline: Bool = false) {
            self.fontName = textStyle.fontName
            self.fontSize = textStyle.fontSize
            self.textColor = textColor
            self.textAlignment = textAlignment
            self.characterSpacing = characterSpacing
            self.lineSpacing = lineSpacing
            self.multiline = multiline
        }
        
        init(fontStyle: FontStyleType, textColor: UIColor = .white, textAlignment: NSTextAlignment = .natural, characterSpacing: CGFloat = 0, lineSpacing: CGFloat = 0, multiline: Bool = false) {
            let textStyle = fontStyle.textStyle
            self.fontName = textStyle.fontName
            self.fontSize = textStyle.fontSize
            self.textColor = textColor
            self.textAlignment = textAlignment
            self.characterSpacing = characterSpacing
            self.lineSpacing = lineSpacing
            self.multiline = multiline
        }

        func font() -> UIFont {
            guard let customFont = UIFont(name: fontName, size: UIFont.labelFontSize) else {
                fatalError("""
                    Failed to load the "\(fontName)" font.
                    Make sure the font file is included in the project and the font name is spelled correctly.
                    """
                )
            }
            return customFont
        }
    }

    struct BorderStyle {
        var borderWidth: CGFloat = 0.0
        var borderColor: UIColor = UIColor.clear
    }

    struct ButtonStyle {
        static let cornerRadiusByHeight: CGFloat = -100
        let textStyle: Style.TextStyle
        let titleColorStyle: Style.StateColorStyle
        let backgroundColorStyle: Style.StateColorStyle
        var cornerRadius: CGFloat = 0.0
        var shadow: Bool = false
        var borderStyle: BorderStyle = BorderStyle()
    }

    struct StateColorStyle {
        let normal: UIColor
        var highlighted: UIColor? = nil
        var disabled: UIColor? = nil
        var selected: UIColor? = nil

        func colorForState(_ state: UIControl.State) -> UIColor? {
            switch state {
            case .normal:
                return normal
            case .highlighted:
                return highlighted
            case .disabled:
                return disabled
            case .selected:
                return selected
            default:
                return normal
            }
        }

        func colorForState(_ state: UIControl.State, prevState: UIControl.State) -> UIColor? {
            let prevColor = colorForState(prevState)
            let currColor = colorForState(state)
            if prevColor == nil {
                return currColor
            }

            return prevColor
        }
    }
}
