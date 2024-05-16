//
//  FirestoreManager.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct FirestoreManager {
    
    static let shared = FirestoreManager()
    
    let db = Firestore.firestore()
}

// MARK: - Waitlist Methods

extension FirestoreManager {
    
    func joinWaitlist(email: String, zip: String, completion: @escaping (Error?) -> ()) {
        db.collection("Waitlist").document(zip).collection("emails").addDocument(data: ["email": email], completion: completion)
    }
}


// MARK: - Notice Methods

extension FirestoreManager {
    
    func fetchNotices(completion: @escaping (Result<[Notice],Error>)->()) {
        db.collection(Constants.FirestoreKeys.notices).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    let notices  = try snapshot?.documents.compactMap({ try $0.data(as: Notice.self )})
                    completion(.success(notices ?? []))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }
    }
}
