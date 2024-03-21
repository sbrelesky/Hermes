//
//  FillUp.swift
//  Hermes
//
//  Created by Shane on 3/4/24.
//

import Foundation
import FirebaseFirestore

enum FillUpStatus: String, Codable {
    case open
    case complete
}

class FillUp: Codable {
    
    @DocumentID var id: String?
    
    var status: FillUpStatus
    var date: Date
    var address: Address
    var cars: [Car]
    var user: User
    var paymentIntentSecret: String
    var deviceToken: String? = UserDefaults.standard.messageToken
    var dateCompleted: Date?
    var totalAmountPaid: Int?
    var totalPaymentIntentId: String?
    
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
        self.paymentIntentSecret = paymentIntentSecret
    }
    
    static let test = FillUp(status: .open, date: Date(), address: Address.test, cars: [Car.test], user: User.test, paymentIntentSecret: "")
}
