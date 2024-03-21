//
//  Firestore+User.swift
//  Hermes
//
//  Created by Shane on 3/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth



// MARK: - User Methods

extension FirestoreManager {
    
    func createUser(firstName: String,phone: String, completion: @escaping (Error?) -> ()){
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else { return }
        
        let data = [
            "firstName": firstName,
            "email": email,
            "phone": phone,
            "dateCreated": Timestamp(date: Date())
        ] as [String : Any]
        
        
        db.collection(Constants.FirestoreKeys.userCollection).document(uid).setData(data) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchUser(completion: @escaping (Result<User, Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.userCollection).document(uid).getDocument(as: User.self, completion: completion)
    }
    
    func saveUser(completion: @escaping (Error?)->()) {
        guard let uid = Auth.auth().currentUser?.uid,
              let user = UserManager.shared.currentUser else { return }
        do {
            try db.collection(Constants.FirestoreKeys.userCollection).document(uid).setData(from: user)
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    func deleteAccount(completion: @escaping (Error?) ->()) {
        guard let uid = Auth.auth().currentUser?.uid,
              let user = UserManager.shared.currentUser else { return }
        do {
            try db.collection(Constants.FirestoreKeys.deletedAccounts).document(uid).setData(from: user) { error in
                if let error = error {
                    completion(error)
                } else {
                    db.collection(Constants.FirestoreKeys.userCollection).document(uid).delete(completion: completion)
                }
            }
        } catch let error {
            completion(error)
        }
    }
    
}
