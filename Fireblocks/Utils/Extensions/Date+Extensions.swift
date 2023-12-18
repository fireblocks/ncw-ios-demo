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
}
