//
//  User+Convenience.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/19/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import CoreData

extension User {
    
    @discardableResult convenience init(email: String, fullname: String, usertype: String, zipcode: String, profileImageURLString: String = "", eventDistance: Int, lastUpdate: Date = Date(), context: NSManagedObjectContext = CoreDataStack.context){
        
        self.init(context: context)
        
        self.email = email
        self.fullname = fullname
        self.usertype = usertype
        self.zipcode = zipcode
        self.eventDistance = eventDistance
        self.lastUpdate = lastUpdate
    }
    
}
