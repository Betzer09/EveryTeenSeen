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
    
    // MARK: - Create a Firebase User
    func createFirebaseUserWith(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                NSLog("Error creating firebase user: \(error.localizedDescription)")
            }
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
    func signUserOut() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
        } catch let error {
            NSLog("Error signing user out: \(error.localizedDescription)")
        }
        
    }
    
}
