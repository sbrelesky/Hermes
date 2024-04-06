//
//  User.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum UserType: String, Codable {
    case basic
    case pro
    case admin
}

class User: Codable {
    
    @DocumentID var id: String?
    
    let email: String
    var type: UserType? = .basic
    
    private var _name: String
    private var _phone: String
    private var _stripeCustomerId: String?
    private var deviceToken: String?
        
    var name: String {
       get {
           return _name
       }
       set {
           _name = newValue
       }
    }
    
    var phone: String{
        get {
            return _phone
        }
        set {
            _phone = newValue
        }
    }   
    
    var stripeCustomerId: String? {
        get {
            return _stripeCustomerId
        }
        set {
            _stripeCustomerId = newValue
        }
     }
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "firstName"
        case email
        case phone
        case cars
        case stripeCustomerId
        case type
        case deviceToken
    }
    
    init(id: String, name: String, email: String, phone: String, stripeCustomerId: String?) {
        self.id = id
        self._name = name
        self.email = email
        self._phone = phone
        self._stripeCustomerId = stripeCustomerId
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _id = try values.decode(DocumentID<String>.self, forKey: .id)
        _name = try values.decode(String.self, forKey: .name)
        email = try values.decode(String.self, forKey: .email)
        _phone = try values.decode(String.self, forKey: .phone)
        _stripeCustomerId = try values.decodeIfPresent(String.self, forKey: .stripeCustomerId)
        type = try values.decodeIfPresent(UserType.self, forKey: .type)
        deviceToken = try values.decodeIfPresent(String.self, forKey: .deviceToken)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_id, forKey: .id)
        try container.encodeIfPresent(id, forKey: .id) // Encodes with a property id if need be
        try container.encode(_name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(_phone, forKey: .phone)
        try container.encode(_stripeCustomerId, forKey: .stripeCustomerId)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
    }
    
    static let test = User(id: "123", name: "Tester", email: "test@gmail.com", phone: "1234567899", stripeCustomerId: nil)
}
