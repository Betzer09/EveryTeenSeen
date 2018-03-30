//
//  UserLocation+Conenience.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/5/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import CoreData

extension UserLocation {
    
    @discardableResult convenience init(latitude: Double, longitude: Double, zip: String, cityName: String, state: String, user: User, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.latitude = latitude
        self.longitude = longitude
        self.zipcode = zip
        self.cityName = cityName
        self.state = state
        self.user = user
    }
    
}
