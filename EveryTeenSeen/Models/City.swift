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
    let zipcode: String
    var count: Int? = 0
    let state: String
    
    // MARK: - Init
    init(city: String, zipcode: String, state: String, count: Int) {
        self.city = city
        self.zipcode = zipcode
        self.state = state
        self.count = count
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case zipcode = "zip_code"
        case city
        case state
        case count
    }
    
}

