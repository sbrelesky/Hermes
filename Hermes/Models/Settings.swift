//
//  File.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation

class Settings: Codable {
    var prices: Prices
    var serviceFee: Double
    
    static let shared = Settings()
    
    // Private initializer to prevent external instantiation
    private init() {
        // Initialize your properties here
        prices = Prices(regular: 0, midgrade: 0, premium: 0, diesel: 0)
        serviceFee = 0.0
    }

    
    // Custom decoding initializer
    private enum CodingKeys: String, CodingKey {
        case prices
        case serviceFee
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prices = try container.decode(Prices.self, forKey: .prices)
        serviceFee = try container.decode(Double.self, forKey: .serviceFee)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(prices, forKey: .prices)
        try container.encode(serviceFee, forKey: .serviceFee)
    }
    
    // Method to update the singleton instance
    func update(with newData: Settings) {
        prices = newData.prices
        serviceFee = newData.serviceFee
    }
}

struct Prices: Codable {
    
    let regular: Double
    let midgrade: Double
    let premium: Double
    let diesel: Double
    
}
