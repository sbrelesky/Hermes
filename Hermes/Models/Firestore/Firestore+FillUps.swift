//
//  Firestore+FillUps.swift
//  Hermes
//
//  Created by Shane on 3/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


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
                    db.collection(Constants.FirestoreKeys.fillUpsCollection).document(newDocumentRef.documentID).getDocument(as: FillUp.self, completion: completion)
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
                    
                    // Update the user's device token if they are an admin
                    
                    if UserManager.shared.currentUser?.type == .admin {
                        db.collection(Constants.FirestoreKeys.userCollection).document(uid).updateData(["deviceToken": token], completion: completion)
                    } else {
                        completion(nil)
                    }
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
            
        } catch let error {
            completion(error)
        }
    }
}
