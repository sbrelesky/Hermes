//
//  SupportManager.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import FirebaseFirestore

class SupportManager {
    
    static let shared = SupportManager()
    
    var openSupportTicket: Support?
    //var supportTickets: [Support] = []
    
    private init() {}
    
    // Functions to interact with Firestore and manage support-related operations
    
    func fetchOpenSupportTicket(completion: @escaping (Error?) -> Void) {
       
        FirestoreManager.shared.fetchSupportItem { result in
            switch result {
            case .success(let support):
                self.openSupportTicket = support
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func createSupportTicket(fillUp: FillUp, completion: @escaping (Result<Support, Error>) -> Void) {
        guard let user = UserManager.shared.currentUser else { return }
        
        let support = Support(status: .open, user: user,fillUp: fillUp, dateCreated: Timestamp())
        FirestoreManager.shared.createSupportTicket(ticket: support) { result in
            switch result {
            case .success(let ticket):
                self.openSupportTicket = ticket
                completion(.success(ticket))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendChatMessage(supportId: String, message: ChatMessage, completion: @escaping (Error?) -> Void) {
        FirestoreManager.shared.sendChatMessage(supportId: supportId, message: message, completion: completion)
    }
    
    func fetchChatForSupportTicket(support: Support, completion: @escaping (Error?) -> Void) -> ListenerRegistration? {
        guard let supportId = support.id else { return nil }
        
        return FirestoreManager.shared.fetchChatForSupport(supportId: supportId) { result in
            switch result {
            case .success(let messages):
                if support.chat == nil {
                    support.chat = []
                }
                
                support.chat = messages
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func markReadMessagesForSupport(_ support: Support, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.markReadMessages(ticket: support) { error in
            if let error = error {
                completion(error)
            } else {
                let unreadMessageIds: Set<String> = Set(support.unreadMessages.compactMap({ $0.id }))
                support.chat?.forEach({ message in
                    if unreadMessageIds.contains(message.id ?? "") {
                        message.read = true
                    }
                })
                
                if support.lastMessage?.senderId != nil, support.lastMessage?.senderId != UserManager.shared.currentUser?.id {
                    support.lastMessage?.read = true
                }
            }
        }
    }
}
