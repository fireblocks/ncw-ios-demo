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
    
    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    var isTrimmedEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}
