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
    
    var imageCount = 0 {
        didSet {
            print("Image count: \(imageCount)")
        }
    }
    
    // Save events to firestore
    func saveEventToFireStoreWith(title: String, dateHeld: Date, userWhoPosted: String , address: String, eventInfo: String, image: UIImage, completion: @escaping (_ success: Bool) -> Void) {
        
        let eventDb = Firestore.firestore()
        let stringDate = Formatter.ISO8601.string(from: dateHeld)
        
        let event = Event(title: title, dateHeld: stringDate, userWhoPosted: userWhoPosted, address: address, eventInfo: eventInfo)
        // Start uploading the image
        PhotoController.shared.uploadEventImageToStorageWith(image: image, eventTitle: title, completion: { (imageURL) in
            guard imageURL != "" else {completion(false); return}
            event.photoURL = imageURL
            
        }) { (hasFinishedPreparingURL) in
            guard hasFinishedPreparingURL else {return}
            
            do {
                let data = try JSONEncoder().encode(event)
                guard let stringDict = String(data: data, encoding: .utf8) else {completion(false); return}
                
                let jsonDict = convertStringToDictWith(string: stringDict)
                
                eventDb.collection(EventController.eventKey).document(event.title).setData(jsonDict)
                completion(true)
                self.fetchAllEvents()
                
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
                self.imageCount += 1
                
                let eventData = document.data()
                
                do {
                    // Convert the dictionary to data
                    guard let data = convertJsonToDataWith(json: eventData) else {
                        eventGroup.leave()
                        self.imageCount -= 1
                        return
                    }
                    
                    let event = try JSONDecoder().decode(Event.self, from: data)
                    
                    self.fetchImageForEventWith(event: event, completion: { (success) in
                        guard success else {eventGroup.leave(); self.imageCount -= 1; return }
                        events.append(event)
                        eventGroup.leave()
                    })
                } catch let e {
                    NSLog("Error decoding data: \(e.localizedDescription)")
                    completion(false)
                    eventGroup.leave()
                    self.imageCount -= 1
                }
            }
            
            eventGroup.notify(queue: .main, execute: {
                self.events = events
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
    
    // MARK: - Push Notifications
    public func subscribeToNewEventsNotification() {
        DispatchQueue.main.async {
            Messaging.messaging().subscribe(toTopic: EventController.newEventsKey)
        }
    }
    
    public func sendNotificaiton() {
        
        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/everyteenseen-2a545/messages:send") else {NSLog("Bad Notificaiton URL"); return}

        let json = [
            "messages": [
                "topic": "\(EventController.newEventsKey)",
                "notification": [
                    "body": "New Events have been posted!",
                    "title": "FCM Message"
                ]
            ]
        ]
        
        var jsonData: Data? {
            return (try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted))
        }
        
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(AppDelegate.serveryKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        guard let endpoint = request.url else {return}
        URLSession.shared.dataTask(with: endpoint) { (_, _, error) in
            if let error = error {
                NSLog("error sending request!: \(error)")
            }
        }.resume()
        
    }
    
}

