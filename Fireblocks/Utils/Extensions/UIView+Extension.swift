//
//  UIView+Extension.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit

extension UIView {
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
    
    static var nibName: String {
        return String(describing: Self.self)
    }
    
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    func fadeOut(duration: TimeInterval = 2, delay: TimeInterval = 3) {
        UIView.animate(withDuration: duration, delay: delay) {
            self.alpha = 0.0
        }
    }
}
