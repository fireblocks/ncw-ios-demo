//
//  CodableParsingExtension.swift
//  Trading
//
//  Created by Fireblocks Ltd. on 19/10/2020.
//  Copyright © 2020 Fireblocks. All rights reserved.
//

import UIKit

extension Encodable {
    func toString()-> String {
        let encoder = JSONEncoder()
        let result: String
        do {
            let data = try encoder.encode(self)
            result = String(decoding: data, as: UTF8.self)
        } catch {
            return ""
        }
        return result
    }
}

extension Optional where Wrapped == String {

    func fromString<T>(_ type: T.Type) -> T? where T: Codable {
        guard let str = self else {
            return nil
        }
        guard  let obj = str.fromString(type) else {
            return nil
        }
        return obj
    }

}

extension String {
    func fromString<T>(_ type: T.Type) -> T? where T: Codable {
        let decoder = JSONDecoder()
        guard  let data = self.data(using: .utf8) else {
            return nil
        }
        let obj: T?
        do {
            obj = try decoder.decode(type, from:data)
        } catch {
            return nil
        }

        return obj
    }
}


extension Dictionary {
    func fromDictionary<T>(_ type: T.Type) -> T? where T: Codable {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [.sortedKeys])
            let result = String(decoding: data, as: UTF8.self)
            return result.fromString(type)
        } catch {
            return nil
        }
    }
}

extension Array {
    func fromArray<T> (_ type: [T].Type) -> [T]? where T: Codable {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [.sortedKeys])
            let result = String(decoding: data, as: UTF8.self)
            return result.fromString(type)
        } catch {
            return nil
        }
    }
}

