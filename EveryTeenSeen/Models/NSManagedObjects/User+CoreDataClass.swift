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
    
    var dictionaryRepresentation: [String: Any] {
        return [emailKey: email, fullnameKey: fullname, userTypeKey: usertype, zipcodeKey: zipcode, profileURLStringKey: profileImageURLString, eventDistanceKey: eventDistance, userInteretsKey: interests?.array]
    }
    
    convenience init?(dictionary: [String: Any], context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        guard let email = dictionary[self.emailKey] as? String,
            let fullname = dictionary[self.fullnameKey] as? String,
            let usertype = dictionary[self.userTypeKey] as? String,
            let zipcode = dictionary[self.zipcodeKey] as? String,
            let profileURLString = dictionary[self.profileURLStringKey] as? String,
            let eventDistance = dictionary[self.eventDistanceKey] as? Int64,
            let interests = dictionary[self.userInteretsKey] as? [Interest] else {return nil}
        
        self.email = email
        self.fullname = fullname
        self.usertype = usertype
        self.zipcode = zipcode
        self.profileImageURLString = profileURLString
        self.eventDistance = eventDistance
        self.interests = NSOrderedSet(array: interests)
    }
    
    var jsonData: Data? {
        return (try? JSONSerialization.data(withJSONObject: dictionaryRepresentation, options: []))
    }
}
