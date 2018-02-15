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
    static let eventKey = "event"
    static let transactionWasUpdatedNotifcation =  Notification.Name("transactionWasUpdated")
    
    // MARK: - Other
    static let shared = EventController()
    
    // MARK: - Properties
    var events: [Event]? = [] {
        didSet {
            NotificationCenter.default.post(name: EventController.transactionWasUpdatedNotifcation, object: nil)
        }
    }

    // Save events to firestore
    func saveEventToFireStoreWith(title: String, dateHeld: Date, userWhoPosted: String , address: String, eventInfo: String) {
        
        let eventDb = Firestore.firestore()
        let stringDate = Formatter.iso8601.string(from: dateHeld)
        
        let event = Event(title: title, dateHeld: stringDate, userWhoPosted: userWhoPosted, address: address, eventInfo: eventInfo )
        
        do {
            let data = try JSONEncoder().encode(event)
            guard let stringDict = String(data: data, encoding: .utf8) else {return}
            
            let jsonDict = convertStringToDictWith(string: stringDict)
            
            eventDb.collection(EventController.eventKey).document(event.title).setData(jsonDict)
            
            self.fetchAllEvents()
            
        } catch let e {
            NSLog("Error creating event!: \(e.localizedDescription) ")
        }
        
    }
    
    // Fetch all events from firestore
    func fetchAllEvents(completion: @escaping(_ success: Bool) -> Void = {_ in}) {
        
        // TODO: - Make it so it only updates with new events and not all of them at the same time 
        let eventdb = Firestore.firestore()
        
        var events: [Event] = []
        
        eventdb.collection(EventController.eventKey).getDocuments { (snapshot, error) in
            if let error = error {
                NSLog("Error fetching Events: \(error)")
                completion(false)
            }
            
            guard let documents = snapshot?.documents else {completion(false); return}
            
            for document in documents {
                let eventData = document.data()
                
                do {
                    // Convert the dictionary to data
                    guard let data = convertJsonToDataWith(json: eventData) else {return}
                    
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    events.append(event)
                    
                } catch let e {
                    NSLog("Error decoding data: \(e.localizedDescription)")
                    completion(false)
                    break
                }
            }
            
            self.events = events
            
            PhotoController.shared.downloadAllEventImages(events: events, completion: { (done) in
                guard done else {return}
                completion(true)
            })
        }
    }
    
    // Update events in firestore
    // Delete events from firestore
    
    
    
    // Filter all events
}
