//
//  Firestore+Support.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension FirestoreManager {
    
    func fetchSupportItem(completion: @escaping (Result<Support?, Error>)->()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection(Constants.FirestoreKeys.supportCollection)
            .whereField("user.id", isEqualTo: uid)
            .whereField("status", isEqualTo: SupportStatus.open.rawValue)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    do {
                        let support  = try snapshot?.documents.compactMap({ try $0.data(as: Support.self )})
                        if let first = support?.first {
                            completion(.success(first))
                        } else {
                            completion(.success(nil))
                        }
                    } catch (let error) {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    
    func fetchChatForSupport(supportId: String, completion: @escaping (Result<[ChatMessage], Error>) -> ()) -> ListenerRegistration {
        let chatRef = db.collection(Constants.FirestoreKeys.supportCollection)
            .document(supportId)
            .collection(Constants.FirestoreKeys.chatSubCollection)
            
        let messageListener = chatRef.order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
                
            guard let snapshot = snapshot else {
                print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(CustomError.unknown))
                return
            }
            
            do {
                let messages = try snapshot.documents.compactMap({ try $0.data(as: ChatMessage.self )})
                completion(.success(messages))
            } catch (let error) {
                completion(.failure(error))
            }
        }
    
        return messageListener
    }
    
    func sendChatMessage(supportId: String, message: ChatMessage, completion: @escaping (Error?) -> ()) {
        let chatRef = db.collection(Constants.FirestoreKeys.supportCollection)
            .document(supportId)
            .collection(Constants.FirestoreKeys.chatSubCollection)
        
        do {
            try chatRef.addDocument(from: message) { error in
                if let error = error {
                    completion(error)
                } else {
                    
                    db.collection(Constants.FirestoreKeys.supportCollection)
                        .document(supportId).updateData([
                            "lastMessage": [
                                "text": message.text,
                                "senderId": message.senderId,
                                "timestamp": message.timestamp
                            ]
                        ], completion: completion)
                }
            }
                
        } catch let error {
            completion(error)
        }
    }
    
    func createSupportTicket(ticket: Support, completion: @escaping (Result<Support, Error>) -> ()) {
        let supportRef = db.collection(Constants.FirestoreKeys.supportCollection).document()
        let supportId = supportRef.documentID
        
        do {
            try supportRef.setData(from: ticket) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    
                    db.collection(Constants.FirestoreKeys.supportCollection).document(supportId).getDocument(as: Support.self, completion: completion)
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func markReadMessages(ticket: Support, completion: @escaping (Error?) -> ()) {
        guard let supportId = ticket.id else { return }
        
        let unreadMessageIds = ticket.unreadMessages.compactMap({ $0.id })
        
        let batch = db.batch()

        let chatRef = db.collection(Constants.FirestoreKeys.supportCollection).document(supportId).collection(Constants.FirestoreKeys.chatSubCollection)
        
        for msgId in unreadMessageIds {
            batch.updateData(["read": true], forDocument: chatRef.document(msgId))
        }
        
        // Update the last message if need be
        if ticket.lastMessage?.senderId != UserManager.shared.currentUser?.id {
            batch.updateData(["lastMessage.read": true], forDocument: db.collection(Constants.FirestoreKeys.supportCollection).document(supportId))
        }
        
        batch.commit(completion: completion)
    }
}
