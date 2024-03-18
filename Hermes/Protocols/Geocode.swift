//
//  Geocode.swift
//  Hermes
//
//  Created by Shane on 3/14/24.
//

import Foundation
import CoreLocation

protocol Geocode : AnyObject {
    func geocodeAddress(_ address: String, completion: @escaping (Result<Location, Error>) -> ())
}

extension Geocode {
    func geocodeAddress(_ address: String, completion: @escaping (Result<Location, Error>) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                print("Geocoding failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                guard let placemark = placemarks?.first else {
                    print("No placemarks found for the address")
                    return
                }
                
                guard placemark.name != nil, placemark.locality != nil, placemark.administrativeArea != nil, placemark.postalCode != nil else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                completion(.success(Location(placemark: placemark, address: Address(from: placemark))))
            }
        }
    }
}
