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
    
    func createInterestWith(user: User, and nameOfInterest: String, completion: @escaping (_ doneUploading: Bool) -> Void) {
        Interest(name: nameOfInterest, user: user)
        UserController.shared.saveToPersistentStore()
        addInterestToFirebase()
        completion(true)
    }
    
    func delete(interest: Interest) {
        guard let moc = interest.managedObjectContext else {return}
        moc.delete(interest)
        UserController.shared.saveToPersistentStore()
        addInterestToFirebase()
    }
    
    func addInterestToFirebase() {
        guard let user = UserController.shared.loadUserProfile(), let email = user.email else {NSLog("Error updating user's interest!"); return}
        let db = Firestore.firestore()
        db.collection("users").document(email).setData(user.dictionaryRepresentation)
    }
}

