//
//  CodableExtension.swift
//  Trading
//
//  Created by Fireblocks Ltd. on 15/11/2020.
//  Copyright © 2020 Fireblocks. All rights reserved.
//

import UIKit

protocol CodableDefaultSource {
    associatedtype Value: Equatable & Codable

    static var defaultValue: Value { get }
}


@propertyWrapper
struct CodableDefaultValue<Provider: CodableDefaultSource>: Codable {
    public var wrappedValue: Provider.Value

    public init() {
        wrappedValue = Provider.defaultValue
    }

    public init(wrappedValue: Provider.Value) {
        self.wrappedValue = wrappedValue
    }
    
    public init(_ wrappedValue: Provider.Value?) {
        self.wrappedValue = wrappedValue ?? Provider.defaultValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            wrappedValue = Provider.defaultValue
        } else {
            wrappedValue = try container.decode(Provider.Value.self)
        }
    }
}


extension CodableDefaultValue: Equatable where Provider.Value: Equatable {}

extension KeyedDecodingContainer {
    func decode<T>(_: CodableDefaultValue<T>.Type, forKey key: Key) throws -> CodableDefaultValue<T> {
       return try decodeIfPresent(CodableDefaultValue<T>.self, forKey: key) ?? CodableDefaultValue()
    }
}

extension KeyedEncodingContainer {
    mutating func encode<T>(_ value: CodableDefaultValue<T>, forKey key: Key) throws {
        guard value.wrappedValue != T.defaultValue else { return }
        try encode(value.wrappedValue, forKey: key)
    }
}
