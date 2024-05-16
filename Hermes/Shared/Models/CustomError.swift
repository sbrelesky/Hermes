//
//  CustomError.swift
//  Hermes
//
//  Created by Shane on 5/7/24.
//


enum CustomError: Error {
    case invalidResponse
    case noData
    case unknown
    case custom(message: String)
    
    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        case .invalidResponse:
            return "Invalid response received"
        case .noData:
            return "No data available"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
