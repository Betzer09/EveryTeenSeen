//
//  EventController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore

class EventController {
    // MARK: - Keys
    private let eventKey = "event"
    
    static let shared = EventController()
    
    var events: [Event] = []
    
    
    // Save events to firestore
    func saveEventToFireStoreWith(title: String, dateHeld: Date, userWhoPosted: User, zipcode: String) {
        
        let eventDb = Firestore.firestore()
        
        let event = Event(title: title, dateHeld: dateHeld, userWhoPosted: userWhoPosted, zipcode: zipcode)
        
        do {
            let data = try JSONEncoder().encode(event)
            guard let stringDict = String(data: data, encoding: .utf8) else {return}
            
            let jsonDict = convertStringToDictWith(string: stringDict)
            
            eventDb.collection(eventKey).document(event.title).setData(jsonDict)
            
        } catch let e {
            NSLog("Error creating event!: \(e.localizedDescription) ")
        }
        
    }
    
    // Update events in firestore
    // Delete events from firestore
    
    // Fetch all events from firestore
    
    // Filter all events
}
