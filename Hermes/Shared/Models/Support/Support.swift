//
//  Support.swift
//  Hermes
//
//  Created by Shane on 3/25/24.
//

import Foundation
import FirebaseFirestore


enum SupportStatus: String, Codable {
    case open
    case complete
}

class Support: Codable {
    
    @DocumentID var id: String?
    var status: SupportStatus
    var user: BaseUser
    var fillUp: FillUp
    var dateCreated: Timestamp
    
    var lastMessage: ChatMessage?
    
    // Set manually
    var chat: [ChatMessage]? = []
        
    var unreadMessages: [ChatMessage] {
        guard let uid = UserManager.shared.currentUser?.id else { return [] }
        return chat?.filter({ $0.senderId != uid && $0.read == false }) ?? []
    }
    
    init(id: String? = nil, status: SupportStatus, user: BaseUser, fillUp: FillUp, dateCreated: Timestamp, chat: [ChatMessage]? = nil) {
        self.id = id
        self.status = status
        self.user = user
        self.fillUp = fillUp
        self.dateCreated = dateCreated
        self.chat = chat
    }
}



// Pull from Subcollection Chat

class ChatMessage: Codable {
    
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Timestamp
    var read: Bool? = false
    
    init(id: String? = nil, senderId: String, text: String, timestamp: Timestamp) {
        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp
    }
}
