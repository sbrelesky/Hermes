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
       
        #if DEBUG
            guard let user = UserManager.shared.currentUser else { return }
            let fillUp = FillUp(status: .open, date: Date(), address: Address.test, cars: [Car.test], user: user, paymentIntentSecret: "")
            //openSupportTicket = .init(id: "12345", status: .open, user: user, fillUp: fillUp,dateCreated: Timestamp())
            completion(nil)
        #else
        
        FirestoreManager.shared.fetchSupportItem { result in
            switch result {
            case .success(let support):
                self.openSupportTicket = support
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
        
        #endif
    }
    
    func createSupportTicket(fillUp: FillUp, completion: @escaping (Result<Support, Error>) -> Void) {
        guard let user = UserManager.shared.currentUser else { return }
        
        #if DEBUG
        self.openSupportTicket = Support(id: "123", status: .open, user: user, fillUp: fillUp, dateCreated: Timestamp(), chat: [])
        #else
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
        #endif
    }
    
    func sendChatMessage(supportId: String, message: ChatMessage, completion: @escaping (Error?) -> Void) {
        // Implement logic to send a chat message within a support ticket
        #if DEBUG
            if openSupportTicket?.id == supportId {
                openSupportTicket?.chat?.append(message)
            }
            completion(nil)
        #else
            FirestoreManager.shared.sendChatMessage(supportId: supportId, message: message, completion: completion)
        #endif
    }
    
    func fetchChatForSupportTicket(support: Support, completion: @escaping (Error?) -> Void) -> ListenerRegistration? {
        guard let supportId = support.id else { return nil }
        
        #if DEBUG
        guard let userid = UserManager.shared.currentUser?.id else { return nil }
        if openSupportTicket?.chat == nil {
            openSupportTicket?.chat = []
        }
        openSupportTicket?.chat?.append(ChatMessage(id: "1", senderId: userid, text: "Hello", timestamp: Timestamp()))
        

        completion(nil)
        return nil
            
        #else
        return FirestoreManager.shared.fetchChatForSupport(supportId: supportId) { result in
            switch result {
            case .success(let messages):
                openSupportTicket?.chat?.append(contentsOf: messages)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
        #endif
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
                
                if support.lastMessage?.senderId != UserManager.shared.currentUser?.id {
                    support.lastMessage?.read = true
                }
            }
        }
    }
}
