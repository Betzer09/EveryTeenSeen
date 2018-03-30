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
    
    /// Create a location for the user and saves it to CoreData
    func createLocationWith(lat: Double, long: Double, zip: String, cityName: String, state: String) {
        let location = UserLocation(latitude: lat, longitude: long, zip: zip, cityName: cityName, state: state)
        saveToPersistentStore(location: location)
    }
    
    func update(location: UserLocation, lat: Double, long: Double, zip: String, cityName: String, state: String) {
        location.latitude = lat
        location.longitude = long
        location.zipcode = zip
        location.cityName = cityName
        location.state = state
        saveToPersistentStore(location: location)
    }
    
    
    func fetchUserLocation() -> UserLocation? {
        let request: NSFetchRequest<UserLocation> = UserLocation.fetchRequest()
        guard let currentLocation = try? CoreDataStack.context.fetch(request).first else {return nil}
        return currentLocation
    }

    /// Saves the user location to CoreData
    func saveToPersistentStore(location: UserLocation) {
        guard let moc = location.managedObjectContext else {return}
        do {
            try moc.save()
            NSLog("Saved User location Succesfully")
        } catch let error {
            NSLog("There was a problem saving the users location to the persitent store: \(error) in function \(#function)")
        }
    }
}
