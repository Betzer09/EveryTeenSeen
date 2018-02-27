//
//  CityController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/6/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage


class CityController {
    
    // MARK: - Keys
    static let cityInfoKey = "cities"
    
    static let shared = CityController()
    
    // MARK: - Fetch City Info Request
    func fetchCityWith(zipcode: String, completion: @escaping(City) -> Void) {
        
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
    func postCityToFirebaseWith(city: String, zipcode: String, state: String) {
        
        // Check to see if the city is alrady there
        checkForTheCityWith(zipcode: zipcode) { (thereIsACity) in
            if thereIsACity {
                // if the city is there increment the count by one
                self.increaseCityAmountUsing(zipcode: zipcode)
            } else {
                // if the city isn't there create the city using the zip as the key because that is Unique
                let city = City(city: city, zipcode: zipcode, state: state, count: 1)
                self.createCityWith(city: city)
            }
        }
    }
    
    // MARK: - Put and Update Cities
    
    private func createCityWith(city: City) {
        let db = Firestore.firestore()
        
        do {
            let data = try JSONEncoder().encode(city)
            guard let stringDict = convertDataToStringDictionary(data: data) else {return}
            let dictionary = convertStringToDictWith(string: stringDict)
            
            db.collection(CityController.cityInfoKey).document(city.zipcode).setData(dictionary)
        } catch let e {
            NSLog("Error Creating City with zipcode: \(city.zipcode) due to error: \(e.localizedDescription)")
        }
    }
    
    private func checkForTheCityWith(zipcode: String, completion: @escaping (_ success: Bool) -> Void) {
        
        let cityDB = Firestore.firestore()
        
        cityDB.collection(CityController.cityInfoKey).document(zipcode).getDocument { (snapshot, error) in
            
            if let error = error {
                NSLog("Error getting the city with zipcode: \(zipcode) due to error: \(error.localizedDescription)")
            }
            
            // Grab data(dictionary) and convert it to data
            if snapshot?.exists == true {
                completion(true)
            } else {
                completion(false)
            }
            
        }
    }
    
    private func increaseCityAmountUsing(zipcode: String) {
        let citydb = Firestore.firestore()
        
        citydb.collection(CityController.cityInfoKey).document(zipcode).getDocument { (snapshot, error) in
            if let error = error {
                NSLog("Error finding city with zipcode: \(zipcode) due to error: \(error.localizedDescription)")
                return
            }
            
            // Grab the snapshot and set the data
            do {
                guard let dictionaryData = snapshot?.data(), let data = convertJsonToDataWith(json: dictionaryData) else {return}
                
                let city = try JSONDecoder().decode(City.self, from: data)
                city.count! += 1
                self.postUpdated(city: city)
                
            } catch let e {
                NSLog("Error decoding City: \(e.localizedDescription)")
            }
            
        }
        
    }
    
    private func postUpdated(city: City) {
        let cityDB = Firestore.firestore()
        
        do {
            let data = try JSONEncoder().encode(city)
            guard let stringDict = convertDataToStringDictionary(data: data) else {return}
            let jsonDict = convertStringToDictWith(string: stringDict)
            cityDB.collection(CityController.cityInfoKey).document(city.zipcode).setData(jsonDict)
        } catch let e {
            NSLog("Error: \(e.localizedDescription)")
        }
        
    }
    
    // MARK: - Functions
    func verifyLocationFor(city: City) -> Bool {
        
        if city.state == "UT" {
            return true
        }
        return false
    }
}
