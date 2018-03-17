//
//  User.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

public enum UserType: String {
    case joinCause = "toJoinTheCause"
    case leadCause = "toLeadTheCause"
}

class User: Codable, Equatable {
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return  lhs.fullname == rhs.fullname && lhs.email == rhs.email 
    }
    
    // MARK: - Properties
    
    let fullname: String
    let email: String
    let zipcode: String
    var userType: String
    
   @discardableResult init(fullname: String, email: String, zipcode: String, userType: String) {
        self.fullname = fullname
        self.email = email
        self.zipcode = zipcode
        self.userType = userType
    }
    
    // MARK: - Codable setUp
    enum CodingKeys: String, CodingKey {
        case fullname
        case email
        case zipcode
        case userType = "user_type"
    }
}
