//
//  Date+Extensions.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 12/12/2023.
//

import Foundation

extension Date {
    func format() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter.string(from: self)

    }
    
    func mediumFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium

        return formatter.string(from: self)

    }

    
    func milliseconds() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd H:mm:ss.SSSS"

        return formatter.string(from: self)
    }
}
