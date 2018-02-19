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
    static let eventWasUpdatedNotifcation =  Notification.Name("eventWasUpdatedNotifcation")
    
    // MARK: - Other
    static let shared = EventController()
    
    // MARK: - Properties
    var events: [Event]? = [] {
        didSet {
            NotificationCenter.default.post(name: EventController.eventWasUpdatedNotifcation, object: nil)
        }
    }
    
    // Save events to firestore
    func saveEventToFireStoreWith(title: String, dateHeld: Date, userWhoPosted: String , address: String, eventInfo: String) {
        
        let eventDb = Firestore.firestore()
        let stringDate = Formatter.ISO8601.string(from: dateHeld)
        
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
    
    
    
    /// Fetchs the events that are new.
    func fetchNewEvents(completion: @escaping (_ success: Bool) -> Void = {_ in}) {
        let eventDB = Firestore.firestore()
        
        var events: [Event] = []
        
        eventDB.collection(EventController.eventKey).addSnapshotListener { (snapshot, error) in
            if let error = error {
                NSLog("Error listening to new events: \(error.localizedDescription)")
                completion(false)
            }
            
            guard let documents = snapshot?.documents else {return}
            
            for document in documents {
                let eventData = document.data()
                
                do {
                    // Convert the dictionary to data
                    guard let data = convertJsonToDataWith(json: eventData) else {completion(false);return}
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    events.append(event)
                } catch let e {
                    NSLog("Error decoding data: \(e.localizedDescription)")
                    completion(false)
                    break
                }
            }
            
            PhotoController.shared.downloadAllEventImages(events: events, completion: { (done) in
                guard done else {return}
                // Wait for it to be done being added on the backend before updating stuff
                self.events?.append(contentsOf: events)
                completion(true)
            })
        }
        
    }
    
    func isPlanningOnAttending(event: Event, wantsToJoin: Bool, completion: @escaping (_ error: String?) -> Void) {
        
        let db = Firestore.firestore()
        
        db.collection("\(EventController.eventKey)").document(event.title).getDocument { (snapshot, error) in
            if let error = error {
                NSLog("Error retriving event: \(error.localizedDescription)")
                completion("\(error)")
            }
            
            guard let data = snapshot?.data() else {completion("Error with the snapshot!"); return}
            
            do {
                guard let data = convertJsonToDataWith(json: data) else {completion("Error converting Json!"); return}
                
                // Convert the dictionary to data
                let event = try JSONDecoder().decode(Event.self, from: data)
                
                let updatedEvent = self.updateAttendingFieldFor(event: event, andWantsToJoin: wantsToJoin)
                
                // Update the event in the array
                self.updateEventInTheArrayWith(event: updatedEvent)
                
                // Push the updated event to firestore
                self.pushUpdatedEventToFirestoreWith(event: updatedEvent)
                
            } catch let e {
                NSLog("Error decoding event! : \(e.localizedDescription)")
                completion("Error decoding event! : \(e.localizedDescription)")
            }
            
        }
        
    }
    
    
    // MARK: - Functions
    private func updateAttendingFieldFor(event: Event, andWantsToJoin: Bool) -> Event {
        
        if andWantsToJoin {
            event.attending += 1
        } else {
            event.attending -= 1
        }
        
        return event
    }
    
    /// Updates the local event in the array
    private func updateEventInTheArrayWith(event: Event) {
        guard var events = events, let index = events.index(of: event) else {NSLog("Error: This event doesn't Exist"); return}
        
        events.remove(at: index)
        events.insert(event, at: index)
    }
    
    private func pushUpdatedEventToFirestoreWith(event: Event) {
        let db = Firestore.firestore()
        
        let attendingKey = "attending"
        
        db.collection(EventController.eventKey).document(event.title).updateData([attendingKey: event.attending]) { (error) in
            if let error = error {
                NSLog("Error updating event: \(event.title) becasue of error: \(error.localizedDescription)")
            }
        }
    }
    
    
}













