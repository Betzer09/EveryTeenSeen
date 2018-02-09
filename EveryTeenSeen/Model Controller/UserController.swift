//
//  UserController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class UserController {
    
    static let shared = UserController()
    let firebaseManger = FirebaseManager()
    
    // MARK: - Create Auth User
    
    func createAuthUser(email: String, pass: String) {
        firebaseManger.createFirebaseUserWith(email: email, password: pass)
    }
    
    // MARK: - Firestore Methods
    
    
}

