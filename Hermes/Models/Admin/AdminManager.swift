//
//  AdminManager.swift
//  Hermes
//
//  Created by Shane on 3/13/24.
//

import Foundation
import Stripe
import FirebaseFirestore

class AdminManager {
    static let shared = AdminManager()
    
    private var openFillUps: [FillUp] = []
    private var completeFillUps: [FillUp] = []
    
    var groupedOpenFillUpsByDate: [Date: [FillUp]] = [:]
    var groupedCompleteFillUpsByDate: [Date: [FillUp]] = [:]
   
    // MARK: - Fill Up Methods
    
    func fetchOpenFillUps(completion: @escaping (Error?) -> ()) {
        guard UserManager.shared.currentUser?.type == .admin else { return }
        
        FirestoreManager.shared.fetchAllFillUps { result in
            switch result {
            case .success(let fillUps):
                self.openFillUps = fillUps.filter({ $0.status == .open }).sorted(by: { $0.date < $1.date })
                self.completeFillUps = fillUps.filter({ $0.status == .complete }).sorted(by: { $0.date < $1.date })
                self.groupFillUpsByDate()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func completeFillUp(_ fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        guard UserManager.shared.currentUser?.type == .admin else { return }
        
        // Fetch the old payment intent
        STPAPIClient.shared.retrievePaymentIntent(withClientSecret: fillUp.paymentIntentSecret) { servicePaymentIntent, error in
            if let error = error {
                completion(error)
            } else {
                // Get the payment method used for the initial payment
                if let paymentMethodId = servicePaymentIntent?.paymentMethodId {
                    
                    self.createPaymentIntentWithMethodId(paymentMethodId: paymentMethodId, fillUp: fillUp) { error in
                        if let error = error {
                            completion(error)
                        } else {
                            self.updateFillUpStatusComplete(fillUp, completion: completion)
                        }
                    }
                }
            }
        }
    }
    
    private func createPaymentIntentWithMethodId(paymentMethodId: String, fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        guard let totalAmountPaid = fillUp.totalAmountPaid, let customerId = fillUp.user.stripeCustomerId else { return }
        
        // Create a new payment intent for the gas charge
        FirebaseFunctionManager.shared.createPaymentIntentForCustomer(amount: totalAmountPaid, customerId: customerId) { result in
            
            switch result {
            case .success(let paymentIntent):
                self.confirmPaymentIntent(paymentMethodId: paymentMethodId, clientSecret: paymentIntent.clientSecret, fillUp: fillUp, completion: completion)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func confirmPaymentIntent(paymentMethodId: String, clientSecret: String, fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        let params = STPPaymentIntentParams(clientSecret: clientSecret)
        params.paymentMethodId = paymentMethodId
        
        // Confirm this payment intent -- Charge the customer for gas
        STPAPIClient.shared.confirmPaymentIntent(with: params) { paymentIntent, error in
            if let error = error {
                completion(error)
            } else {
                fillUp.totalPaymentIntentId = paymentIntent?.stripeId
                completion(nil)
            }
        }
    }
    
    private func updateFillUpStatusComplete(_ fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        
        fillUp.dateCompleted = Date()
        
        FirestoreManager.shared.setFillUpComplete(fillUp: fillUp) { error in
            if let error = error {
                completion(error)
            } else {
                if let idx = self.openFillUps.firstIndex(where: { $0.id == fillUp.id }) {
                    fillUp.status = .complete
                    
                    self.openFillUps.remove(at: idx)
                    self.completeFillUps.append(fillUp)
                    self.groupFillUpsByDate()
                }
                
                completion(nil)
            }
        }
    }
    
    
    
    // MARK: - Settings Methods
    
    func updateSettings(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.updateSettings { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    
    // MARK: - Helper Methods
    
    private func groupFillUpsByDate() {
        groupOpenFillUps()
        groupCompleteFillUps()
    }
    
    private func groupOpenFillUps() {
        var groupedFillUps: [Date: [FillUp]] = [:]
        groupedOpenFillUpsByDate = [:]
        
        for fillUp in openFillUps {
            let date = Calendar.current.startOfDay(for: fillUp.date)
            
            if var array = groupedFillUps[date] {
                array.append(fillUp)
                groupedFillUps[date] = array
            } else {
                groupedFillUps[date] = [fillUp]
            }
        }
        
        let sortedGroups = groupedFillUps.sorted { $0.key < $1.key }
        sortedGroups.forEach { item in
            print("Date: ", item.key)
            groupedOpenFillUpsByDate[item.key] = item.value
        }
        
        print("After sorting")
        groupedOpenFillUpsByDate.forEach { item in
            print("Date: ", item.key)
        }
    }
    
    private func groupCompleteFillUps() {
        var groupedFillUps: [Date: [FillUp]] = [:]
        groupedCompleteFillUpsByDate = [:]

        for fillUp in completeFillUps {
            let date = Calendar.current.startOfDay(for: fillUp.date)
            if var array = groupedFillUps[date] {
                array.append(fillUp)
                groupedFillUps[date] = array
            } else {
                groupedFillUps[date] = [fillUp]
            }
        }
        
        let sortedGroups = groupedFillUps.sorted { $0.key < $1.key }
        sortedGroups.forEach { item in
            groupedCompleteFillUpsByDate[item.key] = item.value
        }
    }
    
    
}
