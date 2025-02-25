//
//  AssetsColors.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import Foundation
import UIKit.UIColor
import SwiftUI

enum AssetsColors: String{
    case alert = "alert"
    case black = "black"
    case darkBlue = "dark_blue"
    case darkerBlue = "darker_blue"
    case disableGray = "disable_gray"
    case gray1 = "gray_1"
    case gray2 = "gray_2"
    case gray3 = "gray_3"
    case gray4 = "gray_4"
    case inProgress = "in_progress"
    case lightBlue = "light_blue"
    case primaryBlue = "primary_blue"
    case success = "success"
    case tapBlue = "tap_blue"
    case warning = "warning"
    case white = "white"
    case background = "background"
}
    
extension AssetsColors {
    func getColor() -> UIColor {
        let colorName = self.rawValue
        guard let color = UIColor(named: colorName) else {
            print("‼️ Unable to load color asset named: \(colorName).")
            return UIColor.white
        }
        
        return color
    }
    
    func color() -> Color {
        let colorName = self.rawValue
        return Color(colorName)
    }
}
