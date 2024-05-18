//
//  File.swift
//  Hermes
//
//  Created by Shane on 3/7/24.
//

import Foundation

class SettingsManager {
  
    static let shared = SettingsManager()
    
    var `settings`: AppSettings = AppSettings(prices: Prices(), serviceFee: 0.0, availableZips: [])
    
    // MARK: - Fetch Data
    
    func fetch(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchSettings { result in
            switch result {
            case .success(let settings):
                self.settings = settings
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
