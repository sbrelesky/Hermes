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
    
    private var _openFillUps: [FillUp] = []
    private var _completeFillUps: [FillUp] = []
    
    var openOrders: [Order] = []
    var completeOrders: [Order] = []
   
    // MARK: - Fill Up Methods
    
    func fetchOpenFillUps(completion: @escaping (Error?) -> ()) {
        guard UserManager.shared.currentUser?.type == .admin else { return }
        
        FirestoreManager.shared.fetchAllFillUps { result in
            switch result {
            case .success(let fillUps):
                self._openFillUps = fillUps.filter({ $0.status == .open }).sorted(by: { $0.date < $1.date })
                self._completeFillUps = fillUps.filter({ $0.status == .complete }).sorted(by: { $0.date > $1.date })
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
                if let idx = self._openFillUps.firstIndex(where: { $0.id == fillUp.id }) {
                    fillUp.status = .complete
                    
                    self._openFillUps.remove(at: idx)
                    self._completeFillUps.append(fillUp)
                    self.groupFillUpsByDate()
                }
                
                completion(nil)
            }
        }
    }
    
    
    
    // MARK: - Settings Methods
    
    func updateSettings(prices: Prices, serviceFee: Double, completion: @escaping (Error?) -> ()) {
        guard UserManager.shared.currentUser?.type == .admin else { return }
        
        SettingsManager.shared.update(prices: prices, serviceFee: serviceFee, completion: completion)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func groupFillUpsByDate() {
        groupOpenFillUps()
        groupCompleteFillUps()
    }
    
    private func groupOpenFillUps() {
        openOrders = []
        var orders: [Order] = []
        
        for fillUp in _openFillUps {
            let date = Calendar.current.startOfDay(for: fillUp.date)
                        
            if let _ = orders.first(where: { $0.date == date }) {
                orders.first(where: { $0.date == date })?.fillUps.append(fillUp)
            } else {
                orders.append(Order(date: date, fillUps: [fillUp]))
            }
        }

        openOrders = orders
    }
    
    private func groupCompleteFillUps() {
        completeOrders = []
        var orders: [Order] = []

        for fillUp in _completeFillUps {
            let date = Calendar.current.startOfDay(for: fillUp.date)
            
            if let _ = orders.first(where: { $0.date == date }) {
                orders.first(where: { $0.date == date })?.fillUps.append(fillUp)
            } else {
                orders.append(Order(date: date, fillUps: [fillUp]))
            }
        }
        
        completeOrders = orders
    }
    
    func getOpenFillUpsForDate(_ date: Date) -> [FillUp] {
        return openOrders.first(where: { $0.date == date})?.fillUps ?? []
    }
    
    func getCompleteFillUpsForDate(_ date: Date) -> [FillUp] {
        return completeOrders.first(where: { $0.date == date})?.fillUps ?? []
    }
}

class Order {
    let date: Date
    var fillUps: [FillUp]
    
    init(date: Date, fillUps: [FillUp]) {
        self.date = date
        self.fillUps = fillUps
    }
    
}
