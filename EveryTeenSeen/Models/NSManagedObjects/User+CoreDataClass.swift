//
//  User+CoreDataClass.swift
//  
//
//  Created by Austin Betzer on 3/19/18.
//
//

import Foundation
import CoreData

public enum UserType: String {
    case joinCause = "toJoinTheCause"
    case leadCause = "toLeadTheCause"
}

@objc(User)
public class User: NSManagedObject {
    private let emailKey = "email"
    private let fullnameKey = "fullname"
    private let userTypeKey = "user_type"
    private let zipcodeKey = "zipcode"
    private let profileURLStringKey = "profile_url_string"
    private let eventDistanceKey = "event_distance"
    private let userInteretsKey = "user_intrests"
    private let lastUpdateKey = "last_update"
    
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
            let eventDistance = dictionary[self.eventDistanceKey] as? Int,
            let interests = dictionary[self.userInteretsKey] as? [Interest],
            let lastUpdate = dictionary[self.lastUpdateKey] as? Date else {return nil}
        
        self.email = email
        self.fullname = fullname
        self.usertype = usertype
        self.zipcode = zipcode
        self.profileImageURLString = profileURLString
        self.eventDistance = eventDistance
        self.interests = NSOrderedSet(array: interests)
        self.lastUpdate = lastUpdate
    }
    
    var jsonData: Data? {
        return (try? JSONSerialization.data(withJSONObject: dictionaryRepresentation, options: []))
    }
}
