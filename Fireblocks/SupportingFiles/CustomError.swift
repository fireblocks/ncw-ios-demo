//
//  CustomError.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/01/2025.
//

import Foundation

enum CustomError: LocalizedError {
    case genericError(String)
}

extension CustomError: CustomStringConvertible {
    var localizedDescription: String {
        return self.description
    }
    
    var description: String {
        switch self {
        case .genericError(let message):
            return message
        }
    }
}

