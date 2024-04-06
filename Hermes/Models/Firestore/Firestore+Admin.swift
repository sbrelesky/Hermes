//
//  Firestore+Admin.swift
//  Hermes
//
//  Created by Shane on 3/21/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth



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
    
    
    // MARK: - Support
    
    func fetchAllSupportItems(completion: @escaping (Result<[Support], Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.supportCollection)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let support  = try snapshot?.documents.compactMap({ try $0.data(as: Support.self )})
                        completion(.success(support ?? []))
                    } catch (let error) {
                        completion(.failure(error))
                    }
                }
            }
        
    }
    
}
