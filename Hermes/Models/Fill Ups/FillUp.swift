//
//  FillUp.swift
//  Hermes
//
//  Created by Shane on 3/4/24.
//

import Foundation
import FirebaseFirestore
import Stripe

enum FillUpStatus: String, Codable {
    case open
    case complete
    case refunded
}

class FillUp: Codable {
    
    @DocumentID var id: String?
    
    var status: FillUpStatus
    var date: Date
    var address: Address
    var cars: [Car]
    var user: User
    var deviceToken: String? = UserDefaults.standard.messageToken
    var dateCompleted: Date?
    var notes: String?
    
    // Stripe Properties
    var refund: Refund?
    var payments: [PaymentIntent]? = []
    
    var serviceFeePaymentIntent: PaymentIntent? {
        if let paymentIntent = payments?.sorted(by: { $0.amount < $1.amount }).first {
            return paymentIntent
        }
        return nil
    }
    
    var formattedDate: String? {
        let components = date.get(.day, .year)
        guard let day = components.day, let year = components.year else { return nil }
        
        return "\(date.monthName()) \(day), \(year)"
    }
    
    init(id: String? = nil, status: FillUpStatus, date: Date, address: Address, cars: [Car], user: User, paymentIntentSecret: String) {
        self.id = id
        self.status = status
        self.date = date
        self.address = address
        self.cars = cars
        self.user = user
        // self.paymentIntentSecret = paymentIntentSecret
    }
    
    static let test = FillUp(status: .open, date: Date(), address: Address.test, cars: [Car.test], user: User.test, paymentIntentSecret: "")
}
