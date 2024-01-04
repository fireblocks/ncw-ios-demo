//
//  Extensions.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import Foundation
import SwiftUI

class GenericDecoder {
    static func decode<T: Codable>(dictionary: Any?) -> T? {
       guard let dictionary = dictionary as? [String: Any] else { return nil }
       var result: T?
       do {
           if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
               result = try JSONDecoder().decode(T.self, from: data)
           }

       } catch {
           //print(error)
       }
       return result
   }
}
