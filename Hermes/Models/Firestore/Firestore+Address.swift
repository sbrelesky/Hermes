//
//  Firestore+Address.swift
//  Hermes
//
//  Created by Shane on 3/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


// MARK: - Address Methods

extension FirestoreManager {
    
    func fetchAddresses(completion: @escaping (Result<[Address], Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.userCollection).document(uid).collection(Constants.FirestoreKeys.addressesSubCollection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                
                do {
                    let addresses  = try snapshot?.documents.compactMap({ try $0.data(as: Address.self )})
                    completion(.success(addresses ?? []))
                } catch (let error) {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func saveAddress(_ address: Address, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let collectionRef = db.collection(Constants.FirestoreKeys.userCollection)
            .document(uid)
            .collection(Constants.FirestoreKeys.addressesSubCollection)
        
        do {
            guard let addressId = address.id else {
                // Add New
                try collectionRef.addDocument(from: address, completion: completion)
                return
            }
            
            // Update
            let data = try Firestore.Encoder().encode(address)
            collectionRef.document(addressId).updateData(data, completion: completion)
        }
        catch let error {
            completion(error)
        }
    }
    
    func deleteAddress(_ address: Address, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let collectionRef = db.collection(Constants.FirestoreKeys.userCollection)
            .document(uid)
            .collection(Constants.FirestoreKeys.addressesSubCollection)
        
        guard let addressId = address.id else {
            completion(nil)
            return
        }
        
        collectionRef.document(addressId).delete(completion: completion)
    }
    
    
    func setDefaultAddress(_ address: Address, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let collectionRef = db.collection(Constants.FirestoreKeys.userCollection)
            .document(uid)
            .collection(Constants.FirestoreKeys.addressesSubCollection)
        
        guard let addressId = address.id else {
            completion(nil)
            return
        }
        
        if let currentDefaultAddress = UserManager.shared.defaultAddress,
           let currentDefaultAddressId = currentDefaultAddress.id {
            collectionRef.document(currentDefaultAddressId).updateData(["isDefault": false]) { error in
                if let error = error {
                    completion(error)
                } else {
                    collectionRef.document(addressId).updateData(["isDefault": true], completion: completion)
                }
            }
        } else {
            collectionRef.document(addressId).updateData(["isDefault": true], completion: completion)
        }
    }
}

