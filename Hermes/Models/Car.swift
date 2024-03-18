//
//  Car.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Car: Codable {
    
    @DocumentID var id: String?
    
    var make: String
    var model: String
    var year: String
    var license: String
    var fuel: FuelType
    var fuelCapacity: CGFloat
    var gasCapUnlockNeeded: String = "Yes"

    
    static let test = Car(id: "1", make: "Audi", model: "A3", year: "2020", license: "XJSW3", fuel: .premium, fuelCapacity: 14.3, gasCapUnlockNeeded: "No")
}

enum FuelType: String, Codable {
    
    case regular
    case midgrade
    case premium
    case diesel
}

