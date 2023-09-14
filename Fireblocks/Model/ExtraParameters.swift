//
//  ExtraParameters.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 28/08/2023.
//

import Foundation
import UIKit

struct ExtraParameters: Codable {
    let contractCallData: String?
    let rawMessageData: RawMessageData?

    struct TypedMessage: Codable {
        let message: String?
        let domain: String?
        var primaryType: String?
        
        enum MessageError: Error {
            case decoding
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let messageDictionary: [String: Any] = try? container.decode([String: Any].self, forKey: .message), let jsonData = try? JSONSerialization.data(withJSONObject: messageDictionary, options: .prettyPrinted) {
                self.message = String(decoding: jsonData, as: UTF8.self)
            } else {
                self.message = nil
            }
            
            if let domainDictionary: [String: Any] = try? container.decode([String: Any].self, forKey: .domain), let jsonData = try? JSONSerialization.data(withJSONObject: domainDictionary, options: .prettyPrinted) {
                self.domain = String(decoding: jsonData, as: UTF8.self)
            } else {
                self.domain = nil
            }
            
            if let primaryType = try? container.decode(String.self, forKey: .primaryType) {
                self.primaryType = primaryType
            } else {
                primaryType = nil
            }
        }
        
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(message, forKey: .message)
        }
        
        enum CodingKeys: String, CodingKey {
            case message
            case domain
            case primaryType
        }
    }
    
    enum Content: Codable {
        case string(String)
        case typedMessage(TypedMessage)
        
        enum ContentError: Error {
            case decoding
        }
        
        init(from decoder: Decoder) throws {
            if let string = try? decoder.singleValueContainer().decode(String.self) {
                self = .string(string)
                return
            }
            if let typedMessage = try? decoder.singleValueContainer().decode(TypedMessage.self) {
                self = .typedMessage(typedMessage)
                return
            }

            throw ContentError.decoding
        }
        
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let string):
                try container.encode(string)
            case .typedMessage(let typedMessage):
                try container.encode(typedMessage)
            }
        }
    }
    
    struct RawMessageData: Codable {
        let messages: [Message]?
    }
    
    struct Message: Codable {
        var content: Content?
        let type: String?
    }
    
}
