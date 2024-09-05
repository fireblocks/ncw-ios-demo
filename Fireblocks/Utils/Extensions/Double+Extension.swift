//
//  Double+Extension.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 17/07/2023.
//

import Foundation

extension Double {
    func formatFractions(fractionDigits: Int = 6) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = fractionDigits
        
        if let formattedString = numberFormatter.string(from: NSNumber(value: self)) {
            return Double(formattedString) ?? self
        }
        
        return self
    }

    public var millisecond: TimeInterval  { return self / 1000 }
    public var milliseconds: TimeInterval { return self / 1000 }
    public var ms: TimeInterval           { return self / 1000 }
    
    public var second: TimeInterval       { return self }
    public var seconds: TimeInterval      { return self }
    
    public var minute: TimeInterval       { return self * 60 }
    public var minutes: TimeInterval      { return self * 60 }
    
    public var hour: TimeInterval         { return self * 3600 }
    public var hours: TimeInterval        { return self * 3600 }
    
    public var day: TimeInterval          { return self * 3600 * 24 }
    public var days: TimeInterval         { return self * 3600 * 24 }

}
