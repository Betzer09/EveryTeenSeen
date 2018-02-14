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
    func saveEventToFireStoreWith(title: String, dateHeld: Date, userWhoPosted: String , address: String, eventInfo: String) {
        
        let eventDb = Firestore.firestore()
        
        let event = Event(title: title, dateHeld: dateHeld, userWhoPosted: userWhoPosted, address: address, eventInfo: eventInfo )
        
        do {
            let data = try JSONEncoder().encode(event)
            guard let stringDict = String(data: data, encoding: .utf8) else {return}
            
            let jsonDict = convertStringToDictWith(string: stringDict)
            
            eventDb.collection(eventKey).document(event.title).setData(jsonDict)
            
        } catch let e {
            NSLog("Error creating event!: \(e.localizedDescription) ")
        }
        
    }
    
    // Fetch all events from firestore
    func fetchAllEvents(completion: @escaping(_ success: Bool) -> Void) {
        let eventdb = Firestore.firestore()
        
        var events: [Event] = []
        
        eventdb.collection(eventKey).getDocuments { (snapshot, error) in
            if let error = error {
                NSLog("Error fetching Events: \(error)")
                completion(false)
            }
            
            guard let documents = snapshot?.documents else {completion(false); return}
            
            for document in documents {
                let eventData = document.data()
                do {
                    // Encode the data first
                    let data = try JSONEncoder().encode(eventData)
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    events.append(event)
                    
                } catch let e {
                    NSLog("Error decoding data: \(e.localizedDescription)")
                    completion(false)
                    break
                }
            }
            
            self.events = events
            completion(true)
        }
    }
    
    // Update events in firestore
    // Delete events from firestore
    
    
    
    // Filter all events
}
