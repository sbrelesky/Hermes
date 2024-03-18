//
//  FiresbaseFunctionsManager.swift
//  Hermes
//
//  Created by Shane on 3/5/24.
//

import Foundation
import Stripe
import FirebaseFunctions
import FirebaseFunctionsCombineSwift

struct CloudFunctionError: Error {
    let code: String
    let message: String
    
    init(code: String, message: String) {
        self.code = code
        self.message = message
    }
    
    init(error: NSError) throws {
        guard let functionsError = error.userInfo[FunctionsErrorDetailsKey] as? [String: Any] else {
            throw CustomError.invalidResponse
        }
        
        self.code = functionsError["code"] as! String
        self.message = functionsError["message"] as! String
    }
}

struct FirebaseFunctionManager {
    
    static let shared = FirebaseFunctionManager()
    
    let functions = Functions.functions()
}

