//
//  Address.swift
//  Hermes
//
//  Created by Shane on 3/2/24.
//

import Foundation
import FirebaseFirestore
import MapKit.MKPlacemark

class Address: Codable {
    
    @DocumentID var id: String?

    var street: String
    var city: String
    var state: String
    var zip: String
    var building: String?
    var apartment: String?
    var entryCode: String?
    
    var isDefault: Bool = false
    
    var formatted: String {
        return "\(street) \(cityStateZip)"
    }
    
    var cityStateZip: String {
        return "\(city), \(state) \(zip)"
    }
    
    init(street: String, city: String, state: String, zip: String, building: String? = nil, apartment: String? = nil, entryCode: String? = nil, isDefault: Bool = false) {
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.building = building
        self.apartment = apartment
        self.entryCode = entryCode
        self.isDefault = isDefault
    }
    
    init(from placemark: CLPlacemark) {
        
        guard let street = placemark.name,
              let city = placemark.locality,
              let state = placemark.administrativeArea,
              let zip = placemark.postalCode else {
            fatalError("Placemark Missing Attributes")
        }
        
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
    }
    
    func convertToPlacemark(completion: @escaping (CLPlacemark?) -> Void) {
        let addressString = "\(street), \(city), \(state) \(zip)"
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let error = error {
                print("Geocoding failed with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemarks found for the address: \(addressString)")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
    
    
    static let test = Address(street: "123 Testing Way", city: "Test", state: "NV", zip: "12345")
    
}
