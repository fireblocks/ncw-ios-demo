//
//  Double+Extension.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 17/07/2023.
//

import Foundation

extension Double {
    func formatWithTwoDecimalPlaces() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        
        if let formattedString = numberFormatter.string(from: NSNumber(value: self)) {
            return formattedString
        }
        
        return String(self)
    }
}
