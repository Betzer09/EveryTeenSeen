//
//  User+Convenience.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/19/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import CoreData

public enum UserType: String {
    case joinCause = "toJoinTheCause"
    case leadCause = "toLeadTheCause"
}

extension User {
    
    @discardableResult convenience init(email: String, fullname: String, usertype: String, zipcode: String, profileImageURLString: String = "", eventDistance: Int64, lastUpdate: Date = Date(), context: NSManagedObjectContext = CoreDataStack.context){
        
        self.init(context: context)
        
        self.email = email
        self.fullname = fullname
        self.usertype = usertype
        self.zipcode = zipcode
        self.eventDistance = eventDistance
        self.lastUpdate = lastUpdate
    }
    
    private var emailKey: String { return "email" }
    private var fullnameKey: String {return "fullname" }
    private var userTypeKey: String { return "user_type" }
    private var zipcodeKey: String { return "zipcode" }
    private var profileURLStringKey: String { return "profile_url_string" }
    private var eventDistanceKey: String { return "event_distance" }
    private var userInteretsKey: String { return "user_intrests" }
    private var lastUpdateKey: String { return "last_update" }
    
    var dictionaryRepresentation: [String: Any] {
        
        var interestNames: [String] = []
        
        if let interests = UserController.shared.loadUserProfile()?.interests {
            guard let castedInterests = interests.array as? [Interest] else {return [:]}
            interestNames = castedInterests.flatMap( { $0.name } )
        }
        return [emailKey: email, fullnameKey: fullname, userTypeKey: usertype, zipcodeKey: zipcode, profileURLStringKey: profileImageURLString, eventDistanceKey: eventDistance, userInteretsKey: interestNames, lastUpdateKey: lastUpdate]
    }
    
    convenience init?(dictionary: [String: Any], context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        guard let email = dictionary[self.emailKey] as? String,
            let fullname = dictionary[self.fullnameKey] as? String,
            let usertype = dictionary[self.userTypeKey] as? String,
            let zipcode = dictionary[self.zipcodeKey] as? String,
            let profileURLString = dictionary[self.profileURLStringKey] as? String,
            let eventDistance = dictionary[self.eventDistanceKey] as? Int64,
            let interests = dictionary[self.userInteretsKey] as? [String],
            let lastUpdate = dictionary[self.lastUpdateKey] as? Date else {
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
        self.interests = NSOrderedSet(array: interestsToReturn)
        self.lastUpdate = lastUpdate
    }
    
    var jsonData: Data? {
        return (try? JSONSerialization.data(withJSONObject: dictionaryRepresentation, options: []))
    }
    
}
