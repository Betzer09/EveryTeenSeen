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
    var count = 0
    let state: String
    var identifer: UUID?
    
    // MARK: - Init
    init(city: String, zip: String, identifer: UUID = UUID(), state: String) {
        self.city = city
        self.zipcode = zip
        self.state = state
        self.identifer = identifer
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case zipcode = "zip_code"
        case city
        case state
        case identifer
    }
    
}

