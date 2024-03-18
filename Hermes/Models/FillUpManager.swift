//
//  FillUpManager.swift
//  Hermes
//
//  Created by Shane on 3/11/24.
//

import Foundation
import FirebaseFirestore

enum DateMaxCapacityResponse {
    case maxCapacity
    case available
}

class FillUpManager {
    static let shared = FillUpManager()
    
    var openFillUps: [FillUp] = []
    var completeFillUps: [FillUp] = []
    var disabledFillUpDates: [Date] = []

    private var listener: ListenerRegistration?
    
    func cleanUp() {
        openFillUps = []
        completeFillUps = []
        disabledFillUpDates = []
        listener?.remove()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Fetch Data
    
    func fetchFillUps(completion: @escaping (Error?) -> ()){
        
        listener = FirestoreManager.shared.observeFillUps { result in
            switch result {
            case .success(let fillUps):
                self.openFillUps = fillUps.filter({ $0.status == .open }).sorted(by: { $0.date < $1.date })
                self.completeFillUps = fillUps.filter({ $0.status == .complete }).sorted(by: { $0.date < $1.date })
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
        
//        FirestoreManager.shared.fetchFillUps { result in
//            switch result {
//            case .success(let fillUps):
//                self.openFillUps = fillUps.filter({ $0.status == .open }).sorted(by: { $0.date < $1.date })
//                self.completeFillUps = fillUps.filter({ $0.status == .complete }).sorted(by: { $0.date < $1.date })
//                completion(nil)
//            case .failure(let error):
//                completion(error)
//            }
//        }
    }
    
    func fetchDisabledDates(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchDisabledDates { result in
            switch result {
            case .success(let dates):
                self.disabledFillUpDates = dates
                
//                let today = Date()
//                if !self.disabledFillUpDates.contains(today){
//                    self.disabledFillUpDates.append(today)
//                }
                
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    // MARK: - Save Data
    
    func scheduleFillUp(_ fillUp: FillUp, completion: @escaping (Error?) -> ()){
        FirestoreManager.shared.scheduleFillUp(fillUp) { result in
            switch result {
            case .success(let fillUp):
//                self.openFillUps.append(fillUp)
//                self.openFillUps = self.openFillUps.filter({ $0.status == .open }).sorted(by: { $0.date < $1.date })
                self.checkDateForMaxCapacity(date: fillUp.date, completion: completion)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    
    private func checkDateForMaxCapacity(date: Date, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.checkDateForMaxCapacity(date: date) { result in
            switch result {
            case .success(let maxCapacityResponse):
                if maxCapacityResponse == .maxCapacity {
                    // Disable the date locally
                    self.disabledFillUpDates.append(date)
                }
                
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    
    // MARK: - Cancel Fill Up
    
    func cancelFillUp(_ fillUp: FillUp, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.cancelFillUp(fillUp) { error in
            if let error = error {
                completion(error)
            } else {
                if let idx = self.openFillUps.firstIndex(where: { $0.id == fillUp.id }) {
                    self.openFillUps.remove(at: idx)
                    self.openFillUps = self.openFillUps.filter({ $0.status == .open }).sorted(by: { $0.date < $1.date })
                }
                
                completion(nil)
            }
        }
    }
    
    // MARK: - Update Fill Up
    
    func updateFillUpsWithToken(_ token: String) {
        print("Updating Fill Up Tokens: ", token)

        FirestoreManager.shared.updateFillUpsWithToken(token) { error in
            if let error = error {
                print(error)
            } else {
                UserDefaults.standard.updateToken(token: token)
            }
        }
    }
    
    
    // MARK: - Observe Data Methods
    
    private func startListeningForFillUps() {
        
   }
   
}
