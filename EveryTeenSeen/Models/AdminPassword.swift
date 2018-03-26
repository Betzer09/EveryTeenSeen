//
//  AdminPassword.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/26/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class AdminPassword: Codable {
    
    // MARK: - Properties
    let password: String
    
    init(password: String) {
        self.password = password
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case password
    }
    
}
