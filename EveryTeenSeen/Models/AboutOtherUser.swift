//
//  AboutOtherUser.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/5/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

// This class is used because we don't wont to initalize other users in the context and this was the other way I could think of doing it.

import Foundation

struct OtherUser {
    
    private static var emailKey: String { return "email" }
    private static var fullnameKey: String {return "fullname" }
    private static var userTypeKey: String { return "user_type" }
    private static var zipcodeKey: String { return "zipcode" }
    private static var profileURLStringKey: String { return "profile_url_string" }
    private static var eventDistanceKey: String { return "event_distance" }
    private static var userInteretsKey: String { return "user_intrests" }
    private static var lastUpdateKey: String { return "last_update" }
    
    let email: String
    let fullname: String
    let usertype: String
    let zipcode: String
    let eventDistance: Int
    let interests: [Interest]
    let profileImageURLString: String
    
    @discardableResult init(email: String, fullname: String, usertype: String, zipcode: String, eventDistance: Int, interests: [Interest], profileImageURLString: String) {
        
        self.email = email
        self.fullname = fullname
        self.usertype = usertype
        self.eventDistance = eventDistance
        self.interests = interests
        self.zipcode = zipcode
        self.profileImageURLString = profileImageURLString
    }
    
     init?(dictionary: [String: Any]) {
        
        guard let email = dictionary[OtherUser.emailKey] as? String,
            let fullname = dictionary[OtherUser.fullnameKey] as? String,
            let usertype = dictionary[OtherUser.userTypeKey] as? String,
            let zipcode = dictionary[OtherUser.zipcodeKey] as? String,
            let profileURLString = dictionary[OtherUser.profileURLStringKey] as? String,
            let eventDistance = dictionary[OtherUser.eventDistanceKey] as? Int,
            let interests = dictionary[OtherUser.userInteretsKey] as? [String] else {
                return nil
        }
        
        var interestsToReturn: [Interest] = []
        
        guard let user = UserController.shared.loadUserProfile() else {NSLog("There is no user to load: \(#function)"); return nil}
        for stringInterest in interests {
            let interest = Interest(name: stringInterest, user: user)
            interestsToReturn.append(interest)
        }
        
        self.email = email
        self.fullname = fullname
        self.usertype = usertype
        self.zipcode = zipcode
        self.profileImageURLString = profileURLString
        self.eventDistance = eventDistance
        self.interests = interestsToReturn
    }
    
    
}
