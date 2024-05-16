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
    
    var gasEstimate: CGFloat?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._id, forKey: .id)
        try container.encode(self.make, forKey: .make)
        try container.encode(self.model, forKey: .model)
        try container.encode(self.year, forKey: .year)
        try container.encode(self.license, forKey: .license)
        try container.encode(self.fuel, forKey: .fuel)
        try container.encode(self.fuelCapacity, forKey: .fuelCapacity)
        try container.encode(self.gasCapUnlockNeeded, forKey: .gasCapUnlockNeeded)
        try container.encodeIfPresent(self.gasEstimate, forKey: .gasEstimate)
    }
    
    static let test = Car(id: "1", make: "Audi", model: "A3", year: "2020", license: "XJSW3", fuel: .premium, fuelCapacity: 14.3, gasCapUnlockNeeded: "No")
}

enum FuelType: String, Codable {
    
    case regular
    case midgrade
    case premium
    case diesel
}

