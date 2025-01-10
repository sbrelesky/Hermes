//
//  GasEstimateAmount.swift
//  Hermes
//
//  Created by Shane on 5/8/24.
//

import Foundation

enum GasEstimateAmount: CGFloat {
    case empty = 0.0
    case quarter = 0.25
    case half = 0.5
    case threeQuarters = 0.75
    case full = 1.0
    
    var text: String {
        switch self {
        case .empty:
            return "Empty"
        case .quarter:
            return "Quarter"
        case .half:
            return "Half"
        case .threeQuarters:
            return "Three Quarters"
        case .full:
            return "Full"
        }
    }
}
