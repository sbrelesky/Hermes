//
//  UserManager+Stripe.swift
//  Hermes
//
//  Created by Shane on 3/5/24.
//

import Foundation
import Stripe
import FirebaseAnalytics

extension UserManager {
    
    // MARK: - Fetch and Set Stripe Customer
    
    func fetchCustomer(completion: @escaping (Error?) -> ()){
        FirebaseFunctionManager.shared.fetchCustomer { result in
            switch result {
            case .success(let customer):
                self.customer = customer
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // MARK: - Create and Set Stripe Customer
    
    func checkForCustomerOrCreate(completion: @escaping (Error?) -> ()) {
        if currentUser?.stripeCustomerId == nil {
            createCustomer { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    func createCustomer(completion: @escaping (Error?) -> ()){
        FirebaseFunctionManager.shared.createCustomer { result in
            switch result {
            case .success(let customer):
                self.customer = customer
                self.currentUser?.stripeCustomerId = customer.id
                HermesAnalytics.shared.logEvent("create_stripe_customer", parameters: ["customer_id": customer.id])
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func savePaymentMethod(paymentMethodId: String, completion: @escaping (Error?) -> ()) {
        FirebaseFunctionManager.shared.savePaymentMethod(paymentMethodId: paymentMethodId) { result in
            switch result {
            case .success(let paymentMethod):
                self.customer?.paymentMethods?.append(paymentMethod)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchPaymentMethods(completion: @escaping (Error?) -> ()) {
 
        FirebaseFunctionManager.shared.fetchPaymentMethods() { result in
            switch result {
            case .success(let paymentMethods):
                self.customer?.paymentMethods = paymentMethods
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}
