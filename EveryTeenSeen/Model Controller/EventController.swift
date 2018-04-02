//
//  EventController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import MapKit

class EventController {
    
    // MARK: - Keys
    static let eventKey = "event"
    static let eventWasUpdatedNotifcation =  Notification.Name("eventWasUpdatedNotifcation")
    static let newEventsKey = "newEvents"
    
    // MARK: - Other
    static let shared = EventController()
    
    // MARK: - Properties
    var events: [Event]? = [] {
        didSet {
            NotificationCenter.default.post(name: EventController.eventWasUpdatedNotifcation, object: nil)
        }
    }
    
    
    // Save events to firestore
    func saveEventToFireStoreWith(title: String, dateHeld: String, eventTime: String, userWhoPosted: String , address: String, eventInfo: String, image: UIImage, completion: @escaping (_ success: Bool) -> Void) {
        
        let eventDb = Firestore.firestore()
        
        let event = Event(title: title, dateHeld: dateHeld, userWhoPosted: userWhoPosted, address: address, eventInfo: eventInfo, eventTime: eventTime)
        
        
        
        // Start uploading the image
        PhotoController.shared.uploadEventImageToStorageWith(image: image, eventTitle: title, completion: { (imageURL) in
            guard imageURL != "" else {completion(false); return}
            event.photoURL = imageURL
            
        }) { (hasFinishedPreparingURL) in
            guard hasFinishedPreparingURL else {return}
            
            do {
                let data = try JSONEncoder().encode(event)
                guard let stringDict = convertDataToStringDictionary(data: data) else {completion(false); return}
                
                let jsonDict = convertStringToDictWith(string: stringDict)
                
                eventDb.collection(EventController.eventKey).document(event.title).setData(jsonDict)
                completion(true)
                
            } catch let e {
                // Unsuccessfually created an event
                NSLog("Error creating event!: \(e.localizedDescription) ")
                completion(false)
            }
        }
    }
    
    // Fetch all events from firestore
    func fetchAllEvents(completion: @escaping(_ success: Bool) -> Void = {_ in}) {
        
        let eventGroup = DispatchGroup()
        
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
                eventGroup.enter()
                
                let eventData = document.data()
                
                do {
                    // Convert the dictionary to data
                    guard let data = convertJsonToDataWith(json: eventData) else {
                        eventGroup.leave()
                        return
                    }
                    
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    
                    self.fetchImageForEventWith(event: event, completion: { (success) in
                        guard success else {eventGroup.leave(); return }
                        events.append(event)
                        eventGroup.leave()
                    })
                } catch let e {
                    NSLog("Error decoding data: \(e.localizedDescription)")
                    completion(false)
                    eventGroup.leave()
                }
            }
            
            eventGroup.notify(queue: .main, execute: {
                let sortedEvent = events.sorted(by: { $0.title < $1.title })
                self.events = sortedEvent
                completion(true)
            })
        }
    }
    
    func fetchImageForEventWith(event: Event, completion: @escaping(_ success: Bool) -> Void) {
        
        guard let stringURL = event.photoURL, let url = URL(string: stringURL) else {NSLog("Error: There is no photoURL for event: \(event.title)"); completion(false); return}
    
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error downloading eventImage for Event: \(event.title) because: \(error.localizedDescription)")
            }
            
            guard let data = data else {completion(false);return}
            
            event.photo = Photo(imageData: data, photoPath: stringURL)
            completion(true)
            
        }.resume()
    }
    
    func isPlanningOnAttending(event: Event, user: User, isGoing: Bool, completion: @escaping (_ stringError: String?) -> Void, completionHandler: @escaping (_ updatedEvent: Event?) -> Void = {_ in}) {
        
        let db = Firestore.firestore()
        
        db.collection("\(EventController.eventKey)").document(event.title).getDocument { (snapshot, error) in
            if let error = error {
                NSLog("Error retriving event: \(error.localizedDescription)")
                completion("\(error)")
            }
            
            guard let data = snapshot?.data() else {completion("Error with the snapshot!"); return}
            
            do {
                guard let data = convertJsonToDataWith(json: data) else {completion("Error converting Json!"); return}
                
                // Get event from firebase
                // Convert the dictionary to data
                let event = try JSONDecoder().decode(Event.self, from: data)
                
                // Update the firebase event
                guard let updatedEvent = self.updateAttendingArrayWithUser(event: event, user: user, isGoing: isGoing) else {NSLog("Error updating event in function: \(#function)"); return}
                // Push event to firebase
                self.pushUpdatedEventToFirestoreWith(event: updatedEvent)
                
                completionHandler(updatedEvent)
                
            } catch let e {
                NSLog("Error decoding event! : \(e.localizedDescription)")
                completion("Error decoding event! : \(e.localizedDescription)")
                completionHandler(nil)
            }
        }
        
    }
    
    
    // MARK: - Functions
    private func updateAttendingArrayWithUser(event: Event, user: User, isGoing: Bool) -> Event? {
        guard let email = user.email else {return nil}
        if isGoing {
             event.attending?.append(email)
        } else {
            guard let index = event.attending?.index(of: email) else {return nil}
            event.attending?.remove(at: index)
        }
        print("Attending property has been updated on: \(event.title)")
        return event
    }

    
    private func pushUpdatedEventToFirestoreWith(event: Event) {
        let db = Firestore.firestore()
        
        let attendingKey = "attending"
        
        db.collection(EventController.eventKey).document(event.title).updateData([attendingKey: event.attending]) { (error) in
            if let error = error {
                NSLog("Error updating event: \(event.title) becasue of error: \(error.localizedDescription)")
            }
            
            NSLog("Event Updated In Firebase!")
        }
    }
}
