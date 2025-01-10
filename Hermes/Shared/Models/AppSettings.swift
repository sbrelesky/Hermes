//
//  AppSettings.swift
//  Hermes
//
//  Created by Shane on 5/15/24.
//

import Foundation


class AppSettings: Codable {
    
    var prices: Prices
    var serviceFee: Double
    var availableZips: [String]
    
    init(prices: Prices, serviceFee: Double, availableZips: [String]) {
        self.prices = prices
        self.serviceFee = serviceFee
        self.availableZips = availableZips
    }
    
    // Custom decoding initializer
    private enum CodingKeys: String, CodingKey {
        case prices
        case serviceFee
        case availableZips
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        prices = try container.decode(Prices.self, forKey: .prices)
        serviceFee = try container.decode(Double.self, forKey: .serviceFee)
        availableZips = try container.decode([String].self, forKey: .availableZips)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(prices, forKey: .prices)
        try container.encode(serviceFee, forKey: .serviceFee)
        try container.encode(availableZips, forKey: .availableZips)
    }
}

struct Prices: Codable {
    
    var regular: Double = 0.0
    var midgrade: Double = 0.0
    var premium: Double = 0.0
    var diesel: Double = 0.0
}
