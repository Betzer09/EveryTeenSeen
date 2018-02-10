//
//  UserController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserController {
    
    static let shared = UserController()
    let firebaseManger = FirebaseManager()
    
    // MARK: - Create Auth User
    
    func createAuthUser(email: String, pass: String) {
        firebaseManger.createFirebaseUserWith(email: email, password: pass)
    }
    
    // MARK: - Firestore Methods
    func createUserProfile(fullname: String, email: String, zipcode: String, userType: UserType ) {
        let userDb = Firestore.firestore()
        
        // Create a user
        let newUser = User(fullname: fullname, email: email, zipcode: zipcode, userType: userType)
        
        do {
            let data = try JSONEncoder().encode(newUser)
            guard let stringDict = String(data: data, encoding: .utf8) else {return}
            let jsonDict = self.convertStringToDictWith(string: stringDict)
            userDb.collection("users").addDocument(data: jsonDict)
        } catch let e {
            NSLog("Error encoding user data: \(e)")
        }
        
    }
    
    // MARK: - String To Dict
    ///Converts json strings to dictionaries
    private func convertStringToDictWith(string: String) -> [String: Any] {
        
        var dict: [String:Any]?
        
        if let data = string.data(using: String.Encoding.utf8) {
            
            do {
                dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        guard let myDictionary = dict else {return [String:Any]()}
        return myDictionary
    }
}









