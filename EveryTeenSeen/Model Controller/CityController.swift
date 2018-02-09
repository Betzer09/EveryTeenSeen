//
//  CityController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/6/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation


class CityController {
    
    static let shared = CityController()
    
    // MARK: - Fetch City Info Request
    func fetchCityWith(zipcode: Int, completion: @escaping(City) -> Void) {
        
        let baseURL = URL(string: "https://www.zipcodeapi.com/rest/iqHRHoIYixbI2qzb3BOsToizMSuzBDN96ruPmbqnBWvEVKUgWcrlrJ9zSytmqVFQ/info.json/\(zipcode)/degrees")!

        URLSession.shared.dataTask(with: baseURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching city with zipcode: \(zipcode) with url: \(baseURL). Error description: \(error.localizedDescription)")
            }
            
            guard let data = data else {NSLog("Error, there is a problem with the City data in function: \(#function)"); return}
            
            do {
                
                let city = try JSONDecoder().decode(City.self, from: data)
                completion(city)
                
            } catch let error {
                print("\(error.localizedDescription)")
            }
            
        }.resume()
    }
    
    // MARK: - Post the location to firebase
    func postCityToFirebaseWith(city: String, zipcode: String, state: String, completion: @escaping (_ success: Bool) -> Void) {
        
        let city = City(city: city, zip: zipcode, state: state)
    
        var putEndpoint = URL(string: "https://everyteenseen-2a545.firebaseio.com")!
        
//        guard let identifer = city.identifer, let endpoint = putEndpoint?.appendingPathComponent(identifer.uuidString).appendingPathExtension(".json") else {return}
        
        var cityData: Data?
        
        // Turn city into Data
        do {
            
        let data = try JSONEncoder().encode(city)
        cityData = data
            
        } catch let error {
            print("Error encoding city data: \(error.localizedDescription) in function: \(#function)")
        }
        
        var request = URLRequest(url: putEndpoint)
        request.httpMethod = "POST"
        request.httpBody = cityData
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            var success = false
            defer {completion (success) }
            
            guard let data = data, let resonceDataString = String(data: data, encoding: .utf8) else {return}
            
            if error != nil {
                NSLog("Error: \(error!)")
            } else if resonceDataString.contains("error") {
                NSLog("Error: \(resonceDataString)")
            } else {
                print("Successfully saved data to endpoint")
                success = true
            }
            
        }.resume()
    }
    
    // MARK: - Functions
    func verifyLocationFor(city: City) -> Bool {
        
        if city.state == "UT" {
            return true
        }
        return false
    }
}











