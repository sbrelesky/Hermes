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
    
    func fetchSettings(completion: @escaping (Result<AppSettings, Error>)->()) {
        db.collection("Settings").document("Nevada").getDocument(as: AppSettings.self, completion: completion)
    }
    
    func updateSettings(completion: @escaping (Error?)->()) {
        do {
            try db.collection("Settings").document("Nevada").setData(from: SettingsManager.shared.settings, completion: completion)
        } catch let error {
            completion(error)
        }
    }
    
}

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
    
    // MARK: - Cars
    
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



// MARK: - Waitlist Methods

extension FirestoreManager {
    
    func joinWaitlist(email: String, zip: String, completion: @escaping (Error?) -> ()) {
        db.collection("Waitlist").document(zip).collection("emails").addDocument(data: ["email": email], completion: completion)
    }
}

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


// MARK: - Fill Up Methods

extension FirestoreManager {
    
    func fetchFillUps(completion: @escaping (Result<[FillUp], Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.fillUpsCollection)
            .whereField("user.id", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let fillUps  = try snapshot?.documents.compactMap({ try $0.data(as: FillUp.self )})
                        completion(.success(fillUps ?? []))
                    } catch (let error) {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func scheduleFillUp(_ fillUp: FillUp, completion: @escaping (Result<FillUp, Error>) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let newDocumentRef = db.collection(Constants.FirestoreKeys.fillUpsCollection).document()
        do {
            try newDocumentRef.setData(from: fillUp) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    db.collection(Constants.FirestoreKeys.fillUpsCollection).document(newDocumentRef.documentID).updateData([
                        "user.id": uid
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            db.collection(Constants.FirestoreKeys.fillUpsCollection).document(newDocumentRef.documentID).getDocument(as: FillUp.self, completion: completion)
                        }
                    }
                    
                }
            }
        } catch let error  {
            completion(.failure(error))
        }
  
    }
    
    func cancelFillUp(_ fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        guard let uid = UserManager.shared.currentUser?.id, let fillUpId = fillUp.id else { return }
    
        db.collection(Constants.FirestoreKeys.fillUpsCollection).document(fillUpId).delete { error in
            if let error = error {
                completion(error)
            } else {
                db.collection(Constants.FirestoreKeys.fillUpsCollection).document(fillUpId).delete(completion: completion)
            }
        }
    }
    
    func updateFillUpsWithToken(_ token: String, completion: @escaping (Error?)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(Constants.FirestoreKeys.fillUpsCollection)
            .whereField("user.id", isEqualTo: uid)
            .whereField("status", isEqualTo: FillUpStatus.open.rawValue)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(error)
                } else {
                    snapshot?.documents.forEach({ snap in
                        snap.reference.updateData(["deviceToken": token])
                    })
                    
                    completion(nil)
                }
            }
    }
    
    func fetchDisabledDates(completion: @escaping (Result<[Date], Error>)->()) {
        db.collection(Constants.FirestoreKeys.disabledDatesCollection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                var disabledDates: [Date] = []
                                
                documents.forEach { document in
                    if let timestamp = document["date"] as? Timestamp{
                        disabledDates.append(timestamp.dateValue())
                    }
                }
                
                completion(.success(disabledDates))
            }
        }
    }
    
    func checkDateForMaxCapacity(date: Date, completion: @escaping (Result<DateMaxCapacityResponse, Error>) -> ()) {
        db.collection(Constants.FirestoreKeys.fillUpsCollection)
            .whereField("date", isEqualTo: date)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if snapshot?.documents.count ?? 0 >= Constants.maxFillUpsPerDate {
                        self.disableDate(date: date) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(.maxCapacity))
                            }
                        }
                    } else {
                        completion(.success(.available))
                    }
                }
            }
    }
    
    func observeFillUps(completion: @escaping (Result<[FillUp], Error>) -> ()) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }

        let observer = db.collection(Constants.FirestoreKeys.fillUpsCollection)
            .whereField("user.id", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let fillUps  = try snapshot?.documents.compactMap({ try $0.data(as: FillUp.self )})
                        completion(.success(fillUps ?? []))
                    } catch (let error) {
                        completion(.failure(error))
                    }
                }
            }
        return observer
    }
    
    
    // MARK: - Helper Methods
    
    private func disableDate(date: Date, completion: @escaping (Error?) -> ()) {
        db.collection(Constants.FirestoreKeys.disabledDatesCollection).addDocument(data: ["date": date], completion: completion)
    }
    
    private func addScheduledFillUpForUser(fillUpId: String, fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        guard let uid = UserManager.shared.currentUser?.id else { return }
        
        do {
            
            let destinationDocumentRef = db.collection(Constants.FirestoreKeys.userCollection)
                .document(uid)
                .collection(Constants.FirestoreKeys.fillUpsCollection)
                .document(fillUpId)
            
            // Set the data to the destination document
            try destinationDocumentRef.setData(from: fillUp) { error in
                if let error = error {
                    print("Error setting destination document data: \(error.localizedDescription)")
                } else {
                    print("Document data successfully copied to destination.")
                }
            }
//            
//            try db.collection(Constants.FirestoreKeys.userCollection).document(uid).collection(Constants.FirestoreKeys.openFillUpsCollection).document(fillUpId).setData(from: fillUp, completion: completion)
            
        } catch let error {
            completion(error)
        }
    }
}

// MARK: - Admin Methods

extension FirestoreManager {
    
    func fetchAllFillUps(completion: @escaping (Result<[FillUp], Error>)->()) {
        guard let _ = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.fillUpsCollection)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let fillUps  = try snapshot?.documents.compactMap({ try $0.data(as: FillUp.self )})
                        completion(.success(fillUps ?? []))
                    } catch (let error) {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    func setFillUpComplete(fillUp: FillUp, completion: @escaping (Error?)->()) {
        guard let _ = Auth.auth().currentUser?.uid, let id = fillUp.id else { return }
        
        
        db.collection(Constants.FirestoreKeys.fillUpsCollection)
            .document(id)
            .updateData([
                "status": FillUpStatus.complete.rawValue,
                "dateCompleted": fillUp.dateCompleted,
                "totalAmountPaid": fillUp.totalAmountPaid,
                "totalPaymentIntentId": fillUp.totalPaymentIntentId
            ], completion: completion)
    }
    
    
}
