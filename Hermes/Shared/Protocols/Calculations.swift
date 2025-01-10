//
//  Calculations.swift
//  Hermes
//
//  Created by Shane on 3/18/24.
//

import Foundation

protocol Calculations {
    func calculateProcessingFee(cost: Double) -> Double
}

extension Calculations {
    func calculateProcessingFee(cost: Double) -> Double {
        return ((cost * Constants.Fees.stripePercentageFee) + Constants.Fees.stripeBaseFee)
    }
}
