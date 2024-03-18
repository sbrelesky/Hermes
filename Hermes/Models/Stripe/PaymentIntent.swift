//
//  PaymentIntent.swift
//  Hermes
//
//  Created by Shane on 3/6/24.
//

import Foundation

struct PaymentIntent: Decodable {
    let id: String
    let clientSecret: String
    let ephemeralKey: String
    let customerId: String
    let amount: Double
}
