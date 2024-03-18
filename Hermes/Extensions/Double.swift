//
//  Double.swift
//  Hermes
//
//  Created by Shane on 3/11/24.
//

import Foundation

extension Double {
    
    func formatCurrency() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current // or specify a different locale if needed
        if let formattedString = formatter.string(from: NSNumber(value: self)) {
            return formattedString
        }
        
        return nil
    }
    
    func truncate(places : Int)-> Double {
       return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
   }
}
