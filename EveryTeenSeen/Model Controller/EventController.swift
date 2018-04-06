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
    
    
    // MARK: - Properties
    static let shared = EventController()
    let firebaseManager = FirebaseManager()
    
    var events: [Event]? = [] {
        didSet {
            NotificationCenter.default.post(name: EventController.eventWasUpdatedNotifcation, object: nil)
        }
    }
    
    
    // MARK: - Firebase Functions
    /// Saves and Updates events to firestore
    func saveEventToFireStoreWith(title: String, dateHeld: String, eventTime: String, userWhoPosted: String , address: String, eventInfo: String, image: UIImage, reports: [[String: String]] = [], completion: @escaping (_ success: Bool) -> Void) {
        
        let eventDb = Firestore.firestore()
        
        let event = Event(title: title, dateHeld: dateHeld, userWhoPosted: userWhoPosted, address: address, eventInfo: eventInfo, eventTime: eventTime)
    
        // Start uploading the image
        PhotoController.shared.uploadImageToStorageWith(image: image, photoTitle: title, completion: { (imageURL) in
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
    
    /// Fetch all events from firestore
    func fetchAllEvents(completion: @escaping(_ success: Bool) -> Void = {_ in}) {
        
        let eventGroup = DispatchGroup()

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
                let sortedEvent = events.sorted(by: { convertStringToDateWith(stringDate: $0.dateHeld)! > convertStringToDateWith(stringDate: $1.dateHeld)!})
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
                self.pushUpdatedAttendingFieldToFirestoreWith(event: updatedEvent)
                
                completionHandler(updatedEvent)
                
            } catch let e {
                NSLog("Error decoding event! : \(e.localizedDescription)")
                completion("Error decoding event! : \(e.localizedDescription)")
                completionHandler(nil)
            }
        }
        
    }
    
    func reportEventWith(userEmail: String, message: String, event: Event, completion: @escaping (_ success: Bool) -> Void) {
        // pull the current event
        let db = Firestore.firestore()
        
        db.collection(EventController.eventKey).document(event.title).getDocument { (snapshot, error) in
            if let error = error {
                NSLog("Error fetching event while reporting it: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = snapshot?.data() else {completion(false); return}
            
            do {
                guard let data = convertJsonToDataWith(json: data) else {completion(false); return}
                let event = try JSONDecoder().decode(Event.self, from: data)
                
                // Update the reports field
                let updatedEvent = self.updateReportArray(userEmail: userEmail, message: message, event: event)
                
                // Push the event back up to firebase
                self.pushUpdatedEventReportFieldToFirestore(event: updatedEvent, completion: { (success) in
                    completion(true)
                })
            } catch let e {
                NSLog("Error decoding event! : \(e.localizedDescription)")
                completion(false)
            }
            
            
        }
    }
    /// Used to update the report property on the event
    private func updateReportArray(userEmail: String, message: String, event: Event) -> Event {

        // Create a report
        let report = [userEmail: message]
        
        // add the report the event
        event.reports?.append(report)
        
        return event
    }
    
    // MARK: - Profile Picture Functions
    
    /// Fetches the first 12 profile pictures
    func fetchAllProfilePicturesFor(event: Event, completion: @escaping (_ images: [Photo]?) -> Void ) {
        guard let userEmails = event.attending else {completion(nil); return}
        
        fetchAllUsersProfileURLSWith(emails: userEmails) { (photos) in
            guard let photos = photos else {return}
            let sortedPhoto = photos.sorted(by: { $0.photoPath < $1.photoPath })
            completion(sortedPhoto)
        }

        
    }
    
    /// Fetches the profile picture URLS for the users attending the event
    private func fetchAllUsersProfileURLSWith(emails: [String], completion: @escaping (_ stringURLS: [Photo]?) -> Void) {
        
        var profilePicures: [Photo] = []
        let userGroup = DispatchGroup()
        if emails.isEmpty {
            completion([])
            return
        }
        
        for email in emails {
            // Makes sure we don't get more than 12 picures
            if profilePicures.count >= 12 {
                break
            }
            
            userGroup.enter()
            firebaseManager.fetchOtherUserFromFirebase(email: email, completion: { (user, error) in
                if let error = error {
                    NSLog("Error retriving \(email)\'s profile due to error: \(error.localizedDescription)")
                    userGroup.leave()
                }
                
                guard let user = user else {
                        userGroup.leave()
                        NSLog("Error fetching All user profile pictures in function: \(#function), returning out of loop function!")
                        return
                }
                
               self.firebaseManager.fetchProfilePicureWith(string: user.profileImageURLString, completion: { (image) in
                guard let image = image, let data = UIImageJPEGRepresentation(image, 1.0) else {return}
                    let photo = Photo(imageData: data, photoPath: email)
                    profilePicures.append(photo)
                    userGroup.leave()
                })
            })
            
            userGroup.notify(queue: .main, execute: {
                completion(profilePicures)
            })
        }
    }
    /// Fetches a users profile with the URL
    private func fetchProfilePicure(with URL: URL, completion: @escaping (_ profileImage: UIImage?) -> Void) {
        
        URLSession.shared.dataTask(with: URL) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching profilepicure with URL \(URL) with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {completion(nil); return}
            completion(image)
            }.resume()
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

    /// Pushes the updated report property to firebase
    private func pushUpdatedEventReportFieldToFirestore(event: Event, completion: @escaping (_ success: Bool) -> Void) {
        let db = Firestore.firestore()
        
        let reportsKey = "reports"
        
        db.collection(EventController.eventKey).document(event.title).updateData([reportsKey: event.reports]) { (error) in
            
            if let error = error {
                NSLog("Error reporting event with title: \(event.title) becasue of error: \(error.localizedDescription)")
                completion(false)
            } else {
                NSLog("Event reported In Firebase!")
                completion(true)
            }
        }
    }
    
    private func pushUpdatedAttendingFieldToFirestoreWith(event: Event) {
        let db = Firestore.firestore()
        
        let attendingKey = "attending"
        db.collection(EventController.eventKey).document(event.title).updateData([attendingKey: event.attending]) { (error) in
            if let error = error {
                NSLog("Error updating event: \(event.title) becasue of error: \(error.localizedDescription)")
            } else {
                
                NSLog("Event Updated In Firebase!")
            }
        }
    }
}
