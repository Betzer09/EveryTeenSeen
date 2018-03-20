//
//  UserLocationController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/5/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class UserLocationController {
    static let shared = UserLocationController() 
    
    func createLocationWith(lat: Double, long: Double, zip: String) {
        UserLocation(latitude: lat, longitude: long, zip: zip)
        saveToPersistentStore()
    }
    
    func update(location: UserLocation, lat: Double, long: Double, zip: String) {
        location.latitude = lat
        location.longitude = long
        location.zipcode = zip
        saveToPersistentStore()
    }
    
    
    func fetchUserLocation() -> UserLocation? {
        let request: NSFetchRequest<UserLocation> = UserLocation.fetchRequest()
        guard let currentLocation = try? CoreDataStack.context.fetch(request).first else {return nil}
        return currentLocation
    }
    
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.context
        
        do {
            try moc.save()
        } catch let error {
            NSLog("There was a problem saving the users location to the persitent store: \(error) in function \(#function)")
        }
    }
}
