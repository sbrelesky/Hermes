//
//  FirebaseFunctions+Customer.swift
//  Hermes
//
//  Created by Shane on 3/9/24.
//

import Foundation
import Stripe
import FirebaseFirestore
import FirebaseFunctions
import FirebaseFunctionsCombineSwift


extension FirebaseFunctionManager {
    
    
    // MARK: - Stripe Customer Method
    
    func createCustomer(completion: @escaping (Result<Customer, Error>)->()) {
        functions.httpsCallable("createStripeCustomer").call { result, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                    completion(.failure(CustomError.invalidResponse))
                    return
                }
                                
                do {
                    let customer = try JSONDecoder().decode(Customer.self, from: data)
                    completion(.success(customer))
                } catch {
                    // Handle decoding errors
                    print("Error decoding data: \(error)")
                }
            }
        }
    }
    
    
    func fetchCustomer(completion: @escaping (Result<Customer, Error>)->()) {
        functions.httpsCallable("retrieveStripeCustomer").call { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                    completion(.failure(CustomError.invalidResponse))
                    return
                }
                                
                do {
                    let customer = try JSONDecoder().decode(Customer.self, from: data)
                    completion(.success(customer))
                } catch {
                    completion(.failure(CustomError.invalidResponse))
                }
            }
        }
    }
    
    func createPaymentIntent(amount: Int, completion: @escaping (Result<PaymentIntent, Error>)->()) {
        functions.httpsCallable("createPaymentIntentForFillUp").call(["amount": amount]) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                    completion(.failure(CustomError.invalidResponse))
                    return
                }
                                
                do {
                    let paymentIntent = try JSONDecoder().decode(PaymentIntent.self, from: data)
                    completion(.success(paymentIntent))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
        
    func refundFillUp(fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        guard let paymentIntent = fillUp.serviceFeePaymentIntent else { return }
        
        functions.httpsCallable("cancelFillUp").call(["fillUpId": fillUp.id, "paymentIntentId": paymentIntent.id]) { result, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
 
    
//    func fetchPaymentIntentForFillUpId(id: String, completion: @escaping (Result<STPPaymentIntent, Error>)->()) {
//        functions.httpsCallable("fetchPaymentIntentForFillUp").call(["fillUpId": id]) { result, error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                guard let result = result else {
//                    completion(.failure(CustomError.noData))
//                    return
//                }
//                
//                guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
//                    completion(.failure(CustomError.invalidResponse))
//                    return
//                }
//                
//                let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
//                
//                guard let paymentIntent =  STPPaymentIntent.decodedObject(fromAPIResponse: json)else {
//                    completion(.failure(CustomError.invalidResponse))
//                    return
//                }
//                
//                completion(.success(paymentIntent))
//            }
//        }
//    }
    
}

