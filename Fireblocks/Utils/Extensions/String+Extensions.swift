//
//  String+Extensions.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation

extension String {
    func capitalized() -> String {
        let firstChar = self.prefix(1).capitalized
        let remainingChars = self.dropFirst()
        return firstChar + remainingChars
    }
    
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func replaceHyphenWithUnderscore() -> String {
        return self.replacingOccurrences(of: "-", with: "_")
    }
}
