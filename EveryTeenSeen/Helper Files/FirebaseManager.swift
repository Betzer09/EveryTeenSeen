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
    
    func fetchProfilePicureWith(string: String, completion: @escaping(_ profilePicutre: UIImage?) -> Void) {
        
        guard let url = URL(string: string) else {NSLog("Error fetching the image for \(string)!")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("There was an error fetching the user's profile picture! : \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {return}
            completion(image)
            
        }.resume()
    }
    
    /// Fetches the user from FireStore and saves them to the phone
    func fetchUserFromFirebaseWith(email: String, completion: @escaping ((_ user: User?, _ error: Error?) -> Void)) {
        
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            }
            
            guard let document = snapshot?.documents.first else {completion(nil, error) ;return}

            let data = document.data()
            
            guard let user = User(dictionary: data, context: CoreDataStack.context) else {
                NSLog("Error decoding user!")
                completion(nil, nil)
                return
            }
            completion(user, nil)
        }
    }
    
    // When you use the other init? it save it to the coredata context.
    /// This is used to fetch a different user other than the one that is already in the context
    func fetchOtherUserFromFirebase(email: String, completion: @escaping ((_ user: OtherUser?, _ error: Error?) -> Void)) {
        
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            }
            
            guard let document = snapshot?.documents.first else {completion(nil, error) ;return}
            
            let data = document.data()
            
            guard let user = OtherUser(dictionary: data) else {
                NSLog("Error decoding user!")
                completion(nil, nil)
                return
            }
            completion(user, nil)
        }
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
