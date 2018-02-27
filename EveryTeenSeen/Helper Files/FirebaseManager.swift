//
//  FirebaseManager.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import Firebase


class FirebaseManager {
    
    // MARK: - Fetch user from firebase
    
    /// Fetches the user from FireStore and saves them to the phone
    func fetchUserFromFirebaseWith(email: String, completion: @escaping ((_ user: User?, _ error: Error?) -> Void)) {
        
        var user: User?
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            }
            
            guard let document = snapshot?.documents.first else {completion(nil, error) ;return}
            
            
            // Codable does not conform to [String: Any] and all the keys so far are [String: String]
            // This was an easy fix which should be fixed later
            let data = document.data() as! [String: String]
            
            do {
                // You have to encode the data before decoding it...
                
                let encodedData = try JSONEncoder().encode(data)
                
                let decodedUser = try JSONDecoder().decode(User.self, from: encodedData)
                user = decodedUser
                // Save to user defaults
                UserController.shared.saveUserToDefaults(fullname: decodedUser.fullname, email: decodedUser.email,
                                                         zipcode: decodedUser.zipcode, userType: decodedUser.userType)
            } catch let e {
                completion(nil, e)
            }
        }
        
        completion(user, nil)
        
    }
    
    // MARK: - Create a Firebase User
    func createFirebaseUserWith(email: String, password: String, completion: @escaping(_ success: Bool) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                NSLog("Error creating firebase user: \(error.localizedDescription)")
                completion(false)
            }
            
            guard user != nil else {return}
            completion(true)
        }
    }
    
    // MARK: - Sign User In
    func signUserInWith(email: String, andPass: String, completion: @escaping ((_ sucess: Bool, _ error: Error?) -> Void)) {
        
        Auth.auth().signIn(withEmail: email, password: andPass) { (user, error) in
            if let error = error {
                completion(false, error)
                NSLog("Error signing user in: \(error.localizedDescription)")
            }
            
            completion(true, error)
        }
    }
    
    // MARK: - Sign User Out
    func signUserOut(completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            completion(true, nil)
        } catch let error {
            completion(false, error)
            NSLog("Error signing user out: \(error.localizedDescription)")
        }
        
    }
    
}
