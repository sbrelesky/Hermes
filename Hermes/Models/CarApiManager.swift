//
//  CarApiManager.swift
//  Hermes
//
//  Created by Shane on 3/1/24.
//

import Foundation

enum CustomError: Error {
    case invalidResponse
    case noData
}

class CarApiManager {
    
    static let shared = CarApiManager()
    
    private var makes: [CarMake] = []
    
    // Key: Make Name , Value: Model
    private var fetchedModels: [String: [CarModel]] = [:]
    
    
    // Fetch list of all makes
    func fetchMakes(completion: @escaping (Result<[CarMake], Error>) -> Void) {
        
        if !makes.isEmpty {
            completion(.success(makes))
            return
        }
        
        CarAPI.fetchData(from: .makes) { (result: Result<CarMakesResponse, Error>) in
            switch result {
            case .success(let response):
                self.makes = response.data
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Fetch list of models for a specific make
    func fetchModelForMake(_ make: String, completion: @escaping (Result<[CarModel], Error>) -> Void) {
        
        if fetchedModels.keys.contains(where: { $0.lowercased() == make.lowercased() }), let modelsForMake = fetchedModels[make] {
            // We already fetched the models for this make
            completion(.success(modelsForMake))
            return
        }
               
        CarAPI.fetchData(from: .models(make: make)) { (result: Result<CarModelsResponse, Error>) in
            switch result {
            case .success(let response):
                let inputString = "This is a (hidden) message."
                let regexPattern = #"\(hidden\)"#
                let regex = try! NSRegularExpression(pattern: regexPattern)

                let filteredData = response.data.filter { model in
                    let range = NSRange(location: 0, length: model.name.count)
                    return regex.firstMatch(in: model.name , options: [], range: range) == nil
                }
                
                //let filteredData = response.data.filter({ $0.name != "** (hidden)"})
                
                self.fetchedModels[make] = filteredData
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchFuelCapacity(model: CarModel, year: String, completion: @escaping (Result<[CarMileage], Error>) -> ()) {
        CarAPI.fetchData(from: .fuelCapacity(modelId: model.id, year: year)) { (result: Result<CarMileageResponse, Error>) in
            switch result {
            case .success(let response):
                if response.data.isEmpty {
                    completion(.failure(CustomError.noData))
                }
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

// https://vpic.nhtsa.dot.gov/api/
// https://car-api2.p.rapidapi.com/api/

struct CarAPI {
    
    static let baseUrl = "https://car-api2.p.rapidapi.com/api"
    static let apiKey = "7467f87e30msh67196589f2ad3edp1790b8jsnda84a8fc0dab"
    static let host = "car-api2.p.rapidapi.com"
    
    enum Endpoint {
        case makes
        case models(make: String)
        case fuelCapacity(modelId: Int, year: String)
        
        var path: String {
            switch self {
            case .makes:
                return "\(CarAPI.baseUrl)/makes?direction=asc&sort=name"
            case .models(let make):
                return "\(CarAPI.baseUrl)/models?make=\(make)&sort=id&direction=asc&verbose=no"
            case .fuelCapacity(let modelId, let year):
                return "\(CarAPI.baseUrl)/mileages?direction=asc&verbose=no&sort=id&year=\(year)&make_model_id=\(modelId)"
            }
        }
    }
    
    static func fetchData<T: Decodable>(from endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint.path) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(CarAPI.apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let responseData = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: responseData)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        
        
        task.resume()
    }
    
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case noData
        // Add more error cases as needed
    }
}


struct CarMakesResponse: Decodable {
    let data: [CarMake]
}

struct CarMake: Decodable, NameProviding {
    
    var id: Int
    var name: String
}

struct CarModelsResponse: Codable {
    let data: [CarModel]
}

struct CarModel: Codable, NameProviding {
    let id: Int
    let makeId: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case makeId = "make_id"
        case name
    }
}

struct CarMileageResponse: Codable {
    let data: [CarMileage]
}

struct CarMileage: Codable {
    let fuelCapacity: String
    
    enum CodingKeys: String, CodingKey {
        case fuelCapacity = "fuel_tank_capacity"
    }
}
