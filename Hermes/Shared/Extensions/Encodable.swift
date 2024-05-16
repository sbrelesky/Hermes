//
//  Encodable.swift
//  Hermes
//
//  Created by Shane on 4/8/24.
//

import Foundation

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw EncodingError.invalidValue(jsonObject, EncodingError.Context(codingPath: [], debugDescription: "Failed to convert JSON object to dictionary"))
        }
        
        return dictionary
    }
}
