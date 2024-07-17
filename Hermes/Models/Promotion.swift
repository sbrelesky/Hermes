//
//  Promotion.swift
//  Hermes
//
//  Created by Shane on 5/23/24.
//

import Foundation

enum PromotionType: String, Codable {
    case signUp = "sign_up"
}

class Promotion: Codable {
    var type: PromotionType
    var discountPercentage: CGFloat // 1.0 = 100% off = Free
    var title: String
    var message: String?
}
