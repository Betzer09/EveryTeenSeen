//
//  City.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/1/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class city: Decodable {
    
    // Added test line
    
    // MARK: - Properties
    let city: String
    let county: String
    let zip: Int
    var count = 0
    
    // MARK: - Init
    init(city: String, county: String, zip: Int) {
        self.city = city
        self.county = county
        self.zip = zip
    }
    
    // MARK: -
    enum CodingKeys: String, CodingKey {
        case city
        case county
        case zip
    }
}

