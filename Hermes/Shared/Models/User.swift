//
//  User.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift



class BaseUser: Codable {
    
    @DocumentID var id: String?
    let email: String
    var type: UserType? = .basic
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case type
        case _name = "firstName"
    }
    
    private var _name: String
    var name: String {
       get {
           return _name
       }
       set {
           _name = newValue
       }
    }
    
    init(id: String, name: String, email: String, type: UserType) {
        self.id = id
        self._name = name
        self.email = email
        self.type = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        _name = try container.decode(String.self, forKey: ._name)
        type = try container.decodeIfPresent(UserType.self, forKey: .type)
        email = try container.decode(String.self, forKey: .email)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: .id)
        try container.encodeIfPresent(id, forKey: .id) // Encodes with a property id if nee
        try container.encode(self._id, forKey: .id)
        try container.encode(self.email, forKey: .email)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encode(self._name, forKey: ._name)
    }
}


enum UserType: String, Codable {
    case basic
    case pro
    case admin
}

class User: BaseUser {
    
    private var _phone: String
    private var _stripeCustomerId: String?
    
    var deviceToken: String?
        
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
        case phone
        case cars
        case stripeCustomerId
        case deviceToken
    }
    
    init(id: String, name: String, type: UserType, email: String, phone: String, stripeCustomerId: String?) {
        self._phone = phone
        self._stripeCustomerId = stripeCustomerId
        
        super.init(id: id, name: name, email: email, type: type)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _phone = try values.decode(String.self, forKey: .phone)
        _stripeCustomerId = try values.decodeIfPresent(String.self, forKey: .stripeCustomerId)
        deviceToken = try values.decodeIfPresent(String.self, forKey: .deviceToken)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_phone, forKey: .phone)
        try container.encode(_stripeCustomerId, forKey: .stripeCustomerId)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
    }
    
    static let test = User(id: "123", name: "Tester", type: .basic, email: "test@gmail.com", phone: "1234567899", stripeCustomerId: nil)
}
