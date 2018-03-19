//
//  User+CoreDataProperties.swift
//  
//
//  Created by Austin Betzer on 3/19/18.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var fullname: String
    @NSManaged public var email: String
    @NSManaged public var zipcode: String
    @NSManaged public var usertype: String
    @NSManaged public var eventDistance: Int64
    @NSManaged public var profileImageURLString: String?

}
