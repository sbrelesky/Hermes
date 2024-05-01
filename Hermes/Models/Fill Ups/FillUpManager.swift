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
                self.completeFillUps = fillUps.filter({ $0.status != .open }).sorted(by: { $0.date > $1.date })
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchDisabledDates(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchDisabledDates { result in
            switch result {
            case .success(let dates):
                self.disabledFillUpDates = dates
                
                // Get the current date and time
                let currentDate = Date()

                // Create a Calendar instance
                let calendar = Calendar.current

                // Get the current hour using the calendar
                let currentHour = calendar.component(.hour, from: currentDate)

                // Check if the current hour is after 10 PM (22:00)
                if currentHour >= Constants.dateCutoffHour, let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    if !self.disabledFillUpDates.contains(tomorrowDate){
                        self.disabledFillUpDates.append(tomorrowDate)
                    }
                }
                
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
        
        FirebaseFunctionManager.shared.refundFillUp(fillUp: fillUp) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
     
}
