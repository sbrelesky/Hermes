//
//  HermesAnalytics.swift
//  Hermes
//
//  Created by Shane on 5/23/24.
//

import Foundation
import FirebaseAnalytics

class HermesAnalytics {
    static let shared = HermesAnalytics()
    
    private init() { }
    
    func logError(_ error: Error, message: String? = nil) {
//        Analytics.logEvent("Error", parameters: [
//            "message": message ?? "unknown",
//            "description": error.localizedDescription
//        ])
    }
    
    func logEvent(_ name: String, parameters: [String: Any]?) {
        // Analytics.logEvent(name, parameters: parameters)
    }
}
