//
//  Refund.swift
//  Hermes
//
//  Created by Shane on 4/8/24.
//

import Foundation

struct Refund: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case paymentIntentId = "payment_intent"
    }
    
    var id: String
    var amount: Int
    var paymentIntentId: String?
    var reason: String?
    var status: String?
}
