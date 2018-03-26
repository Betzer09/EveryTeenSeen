//
//  InterestController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/19/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class InterestController {
    static let shared = InterestController()
    
    func createInterestWith(user: User, and nameOfInterest: String) {
        let newInterest = Interest(name: nameOfInterest, user: user)
        user.addToInterests(newInterest)
        UserController.shared.saveToPersistentStore()
        addInterestToFirebase()
    }
    
    func delete(interest: Interest) {
        guard let moc = interest.managedObjectContext else {return}
        moc.delete(interest)
        UserController.shared.saveToPersistentStore()
    }
    
    func addInterestToFirebase() {
        guard let user = UserController.shared.loadUserProfile() else {NSLog("Error updating user's interest!"); return}
        let db = Firestore.firestore()
        db.collection("users").document(user.email).setData(user.dictionaryRepresentation)
    }
}

