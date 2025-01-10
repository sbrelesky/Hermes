//
//  Firestore+Cars.swift
//  Hermes
//
//  Created by Shane on 3/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


// MARK: - Cars

extension FirestoreManager {
    
    func fetchCars(completion: @escaping (Result<[Car], Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.userCollection).document(uid).collection(Constants.FirestoreKeys.carsSubCollection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                
                do {
                    let cars  = try snapshot?.documents.compactMap({ try $0.data(as: Car.self )})
                    completion(.success(cars ?? []))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveCar(_ car: Car, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let collectionRef = db.collection(Constants.FirestoreKeys.userCollection)
            .document(uid)
            .collection(Constants.FirestoreKeys.carsSubCollection)
        
        do {
            guard let carId = car.id else {
                try collectionRef.addDocument(from: car, completion: completion)
                return
            }
            
            let data = try Firestore.Encoder().encode(car)
            collectionRef.document(carId).updateData(data, completion: completion)
        }
        catch let error {
            completion(error)
        }
    }
    
    
    func deleteCar(_ car: Car, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let collectionRef = db.collection(Constants.FirestoreKeys.userCollection)
            .document(uid)
            .collection(Constants.FirestoreKeys.carsSubCollection)
        
        guard let carId = car.id else {
            completion(nil)
            return
        }
        
        collectionRef.document(carId).delete(completion: completion)
    }
    
}
