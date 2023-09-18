//
//  Double+Extension.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 17/07/2023.
//

import Foundation

extension Double {
    func formatFractions(fractionDigits: Int) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = fractionDigits
        
        if let formattedString = numberFormatter.string(from: NSNumber(value: self)) {
            return Double(formattedString) ?? self
        }
        
        return self
    }

}
