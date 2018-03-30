//
//  City.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/1/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class City: Codable {
    
    // MARK: - Properties
    let cityName: String
    let zipcode: String
    var count: Int? = 0
    let state: String
    let latitude: Double
    let longitude: Double
    
    // MARK: - Init
    init(city: String, zipcode: String, state: String, count: Int, latitude: Double, longitude: Double) {
        self.cityName = city
        self.zipcode = zipcode
        self.state = state
        self.count = count
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case zipcode = "zip_code"
        case cityName = "city"
        case state
        case count
        case latitude = "lat"
        case longitude = "lng"
    }
    
}

