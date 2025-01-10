//
//  Firestore+Settings.swift
//  Hermes
//
//  Created by Shane on 5/11/24.
//

import Foundation
import FirebaseFirestore

// MARK: - Settings Methods

extension FirestoreManager {
    
    func fetchSettings(completion: @escaping (Result<AppSettings, Error>)->()) {
        db.collection("Settings").document("Nevada").getDocument(as: AppSettings.self, completion: completion)
    }
    
}
