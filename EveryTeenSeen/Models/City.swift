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
    let city: String
    let county: String
    let zipcode: Int
    var count = 0
    let identifer: UUID
    
    // MARK: - Init
    init(city: String, county: String, zip: Int, identifer: UUID = UUID()) {
        self.city = city
        self.county = county
        self.zipcode = zip
        self.identifer = identifer
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case zipcode = "zip_code"
        case city
        case county
        case identifer
        case count
    }
    
}

struct Cities {
    var cities: City
}
