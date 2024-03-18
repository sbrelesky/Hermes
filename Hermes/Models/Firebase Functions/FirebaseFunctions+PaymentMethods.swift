//
//  FirebaseFunctions+PaymentMethods.swift
//  Hermes
//
//  Created by Shane on 3/9/24.
//

import Foundation
import Stripe
import FirebaseFunctions
import FirebaseFunctionsCombineSwift


// MARK: - Payment Method Methods

extension FirebaseFunctionManager {
    
    func savePaymentMethod(paymentMethodId: String, completion: @escaping (Result<STPPaymentMethod, Error>)->()) {
        
        functions.httpsCallable("createPaymentMethod").call(["paymentMethodId": paymentMethodId]) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                do {
                    guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                    guard let paymentMethod = STPPaymentMethod.decodedObject(fromAPIResponse: json) else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    completion(.success(paymentMethod))
                    
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchPaymentMethods(completion: @escaping (Result<[STPPaymentMethod], Error>)->()) {
        
        functions.httpsCallable("retrievePaymentMethods").call() { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                do {
                    guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data) as? [[String:Any]]
                    
                    guard let paymentMethods = json?.compactMap({ STPPaymentMethod.decodedObject(fromAPIResponse: $0)}) else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    completion(.success(paymentMethods))
                    
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createEphemeralKey(completion: @escaping (Result<String, Error>)->()) {
        functions.httpsCallable("createEphemeralKey").call() { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                do {
                    guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                    guard let ephemeralKey = json?["ephemeralKey"] as? String else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    completion(.success(ephemeralKey))
                    
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createEphemeralKey() async throws -> String {
        do {
            let result = try await functions.httpsCallable("createEphemeralKey").call()
            guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                throw CustomError.invalidResponse
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
            guard let ephemeralKey = json?["ephemeralKey"] as? String else {
                throw CustomError.invalidResponse
            }
            
            return ephemeralKey
        } catch {
            throw error
        }
    }
    
    func createSetupIntent(completion: @escaping (Result<STPSetupIntent, Error>)->()) {
        functions.httpsCallable("createSetupIntent").call() { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let result = result else {
                    completion(.failure(CustomError.noData))
                    return
                }
                
                do {
                    guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
                    
                    guard let setupIntent =  STPSetupIntent.decodedObject(fromAPIResponse: json)else {
                        completion(.failure(CustomError.invalidResponse))
                        return
                    }
                    
                    completion(.success(setupIntent))
                    
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createSetupIntent() async throws -> STPSetupIntent {
        do {
            let result = try await functions.httpsCallable("createSetupIntent").call()
            guard let data = try? JSONSerialization.data(withJSONObject: result.data, options: []) else {
                throw CustomError.invalidResponse
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
           
            guard let setupIntent =  STPSetupIntent.decodedObject(fromAPIResponse: json)else {
                throw CustomError.invalidResponse
            }
            
            
            return setupIntent
        } catch {
            throw error
        }
    }
    
}
