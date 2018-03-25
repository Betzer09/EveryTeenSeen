//
//  User+CoreDataProperties.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/20/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String
    @NSManaged public var eventDistance: Int
    @NSManaged public var fullname: String
    @NSManaged public var profileImageURLString: String?
    @NSManaged public var usertype: String
    @NSManaged public var zipcode: String
    @NSManaged public var lastUpdate: Date
    @NSManaged public var interests: NSOrderedSet?

}

// MARK: Generated accessors for interests
extension User {

    @objc(insertObject:inInterestsAtIndex:)
    @NSManaged public func insertIntoInterests(_ value: Interest, at idx: Int)

    @objc(removeObjectFromInterestsAtIndex:)
    @NSManaged public func removeFromInterests(at idx: Int)

    @objc(insertInterests:atIndexes:)
    @NSManaged public func insertIntoInterests(_ values: [Interest], at indexes: NSIndexSet)

    @objc(removeInterestsAtIndexes:)
    @NSManaged public func removeFromInterests(at indexes: NSIndexSet)

    @objc(replaceObjectInInterestsAtIndex:withObject:)
    @NSManaged public func replaceInterests(at idx: Int, with value: Interest)

    @objc(replaceInterestsAtIndexes:withInterests:)
    @NSManaged public func replaceInterests(at indexes: NSIndexSet, with values: [Interest])

    @objc(addInterestsObject:)
    @NSManaged public func addToInterests(_ value: Interest)

    @objc(removeInterestsObject:)
    @NSManaged public func removeFromInterests(_ value: Interest)

    @objc(addInterests:)
    @NSManaged public func addToInterests(_ values: NSOrderedSet)

    @objc(removeInterests:)
    @NSManaged public func removeFromInterests(_ values: NSOrderedSet)

}
