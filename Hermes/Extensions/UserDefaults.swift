//
//  UserDefaults.swift
//  Hermes
//
//  Created by Shane on 3/13/24.
//

import Foundation

extension UserDefaults {
    
    var messageToken: String? {
        return string(forKey: Constants.UserDefaults.messageToken)
    }
    
    func updateToken(token: String) {
        setValue(token, forKey: Constants.UserDefaults.messageToken)
    }
}
