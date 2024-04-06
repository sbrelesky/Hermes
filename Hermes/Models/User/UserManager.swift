//
//  UserManager.swift
//  Hermes
//
//  Created by Shane on 2/29/24.
//

import Foundation
import FirebaseAuth

class UserManager {
    
    static let shared = UserManager()
    
    var currentUser: User?
    var cars: [Car] = []
    var addresses: [Address] = []
    
    var customer: Customer?
    
    var defaultAddress: Address? {
        return addresses.first(where: { $0.isDefault })
    }
    
    private init() {}
    
    func cleanUp() {
        self.currentUser = nil
        self.cars = []
        self.addresses = []
        self.customer = nil
    }

    
    // MARK: - Fetch and Set Current User
    
    func fetch(completion: @escaping (Error?) -> ()){
        
        #if DEBUG
            self.currentUser = User.test
            completion(nil)
        #else
        FirestoreManager.shared.fetchUser { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
        #endif
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            cleanUp()
            FillUpManager.shared.cleanUp()
        } catch {
            throw error
        }
    }
    
    func resetPassword(completion: @escaping (Error?)->()) {
        guard let email = currentUser?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    func update(name: String, phone: String, completion: @escaping (Error?)->()) {
        self.currentUser?.name = name
        self.currentUser?.phone = phone
        
        FirestoreManager.shared.saveUser(completion: completion)
    }
    
    func deleteAccount(completion: @escaping (Error?)->()) {
        FirestoreManager.shared.deleteAccount(completion: completion)
    }
}


// MARK: - Car Methods

extension UserManager {
    // Fetch and set users' cars
    func fetchCars(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchCars { result in
            switch result {
            case .success(let cars):
                self.cars = cars
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }

    func saveCar(_ car: Car, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.saveCar(car) { error in
            if let error = error {
                completion(error)
            } else {
                if car.id == nil {
                    self.cars.append(car)
                } else {
                    self.cars.removeAll(where: { $0.id == car.id })
                    self.cars.append(car)
                }
                
                completion(nil)
            }
        }
    }
    
    func deleteCar(_ car: Car, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.deleteCar(car) { error in
            if let error = error {
                completion(error)
            } else {
                if let index = self.cars.firstIndex(where: { $0.id == car.id }) {
                    self.cars.remove(at: index)
                    completion(nil)
                }
            }
        }
    }
}

// MARK: - Address Methods

extension UserManager {
    
    // Fetch and set users' cars
    func fetchAddresses(completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.fetchAddresses { result in
            switch result {
            case .success(let addresses):
                self.addresses = addresses.sorted(by: { $0.isDefault && !$1.isDefault })
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func saveAddress(_ address: Address, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.saveAddress(address) { error in
            if let error = error {
                completion(error)
            } else {
                if self.addresses.isEmpty {
                    address.isDefault = true
                }
                
                if address.id == nil {
                    self.addresses.append(address)
                } else {
                    self.addresses.removeAll(where: { $0.id == address.id })
                    self.addresses.append(address)
                }
                
                completion(nil)
            }
        }
    }
    
    
    func deleteAddress(_ address: Address, completion: @escaping (Error?) -> ()) {
        FirestoreManager.shared.deleteAddress(address) { error in
            if let error = error {
                completion(error)
            } else {
                if let index = self.addresses.firstIndex(where: { $0.id == address.id }) {
                    self.addresses.remove(at: index)
                                        
                    completion(nil)
                }
            }
        }
    }
    
    func setDefaultAddress(_ address: Address, completion: @escaping (Error?) -> ()) {        
        FirestoreManager.shared.setDefaultAddress(address) { error in
            if let error = error {
                completion(error)
            } else {
                if let defaultAddressId = UserManager.shared.defaultAddress?.id {
                    UserManager.shared.addresses.first(where: {$0.id == defaultAddressId })?.isDefault = false
                }
                
                UserManager.shared.addresses.first(where: {$0.id == address.id })?.isDefault = true
                completion(nil)
            }
        }
    }
}
