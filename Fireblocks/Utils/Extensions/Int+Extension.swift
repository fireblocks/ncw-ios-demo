//
//  Int+Extension.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation

extension Int {
    func toDateFormattedString() -> String {
        let timestamp = TimeInterval(self) / 1000
        let date = Date(timeIntervalSince1970: timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let formattedString = dateFormatter.string(from: date)
        
        return formattedString
    }
}

extension Encodable {
    func dictionary() -> [String:Any] {
        var dict = [String:Any]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let key = child.label else { continue }
            let childMirror = Mirror(reflecting: child.value)
            
            switch childMirror.displayStyle {
            case .struct, .class:
                let childDict = (child.value as! Encodable).dictionary()
                dict[key] = childDict
            case .collection:
                let childArray = (child.value as! [Encodable]).map({ $0.dictionary() })
                dict[key] = childArray
            case .set:
                let childArray = (child.value as! Set<AnyHashable>).map({ ($0 as! Encodable).dictionary() })
                dict[key] = childArray
            default:
                dict[key] = child.value
            }
        }
        
        return dict
    }
    
    func toData() -> Data? {
        return try? JSONEncoder().encode(self)
    }

}

extension Decodable {
    static func fromData(_ data: Data?) -> Self? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}

