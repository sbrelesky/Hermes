//
//  Notice.swift
//  Hermes
//
//  Created by Shane on 3/20/24.
//

import Foundation

class Notice: Decodable {
    
    var title: String
    var message: String
    var systemImageName: String?
    var dismissable: Bool = true

    enum CodingKeys: CodingKey {
        case title
        case message
        case systemImageName
        case dismissable
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.message = try container.decode(String.self, forKey: .message)
        self.systemImageName = try container.decodeIfPresent(String.self, forKey: .systemImageName)
        self.dismissable = try container.decodeIfPresent(Bool.self, forKey: .dismissable) ?? true
    }
}
