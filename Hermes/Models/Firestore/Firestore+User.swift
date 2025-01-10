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
import FirebaseAnalytics


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
                
                fetchPromotions(for: .signUp) { result in
                    switch result {
                    case .success(let promos):
                        if let promo = promos.first {
                            do {
                                try db.collection(Constants.FirestoreKeys.userCollection)
                                    .document(uid)
                                    .collection(Constants.FirestoreKeys.promosSubCollection)
                                    .addDocument(from: promo)
                            } catch (let error) {
                                print("Error saving promo: ", error)
                                HermesAnalytics.shared.logError(error, message: "Error saving promotion to user: \(uid)")
                            }
                        }
                    case .failure(let error):
                        print("Error fetching promos: ", error)
                        HermesAnalytics.shared.logError(error, message: "Error fetching promotions")
                    }
                }
                
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
    
    func updateUserToken(_ token: String, completion: @escaping (Error?)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.userCollection).document(uid).updateData(["deviceToken": token], completion: completion)
    }
        
    func fetchAllPromotions(completion: @escaping (Result<[Promotion],Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.userCollection).document(uid).collection(Constants.FirestoreKeys.promosSubCollection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    let promos  = try snapshot?.documents.compactMap({ try $0.data(as: Promotion.self )})
                    completion(.success(promos ?? []))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }
    }
}
