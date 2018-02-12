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
    
    // MARK: - Keys
    private let fullnameKey = "fullname"
    private let emailKey = "email"
    private let zipcodeKey = "zipcode"
    private let userTypeKey = "user_Type"
    
    // MARK: - Create Auth User
    
    func createAuthUser(email: String, pass: String) {
        firebaseManger.createFirebaseUserWith(email: email, password: pass)
    }
    
    // MARK: - Firestore Methods
    func createUserProfile(fullname: String, email: String, zipcode: String, userType: UserType, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) ) {
        let userDb = Firestore.firestore()
        
        // Create a user
        let newUser = User(fullname: fullname, email: email, zipcode: zipcode, userType: userType.rawValue)
        
        do {
            let data = try JSONEncoder().encode(newUser)
            guard let stringDict = String(data: data, encoding: .utf8) else {completion(false,nil); return}
            let jsonDict = self.convertStringToDictWith(string: stringDict)
            
            switch userType {
            case .joinCause:
                userDb.collection("users").addDocument(data: jsonDict)
                print("Succesfully Created User")
                completion(true, nil)
            case .leadCause:
                userDb.collection("admin_users").addDocument(data: jsonDict)
                print("Succesfully Admin Created User")
                completion(true, nil)
            }
        } catch let e {
            completion(false, e)
            print("Error Createing User")
            NSLog("Error encoding user data: \(e)")
        }
        
    }
    
    func signUserInWith(email: String, password: String, completion: @escaping((_ success: Bool, _ error: Error?) -> Void)) {
        firebaseManger.signUserInWith(email: email, andPass: password) { (success, error) in
            completion(success, error)
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
    
    // MARK: - Save User To Defaults
    
    /// Saves the currents user to userdefaults
    func saveUserToDefaults(fullname: String, email: String, zipcode: String, userType: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(fullname, forKey: fullnameKey)
        defaults.set(email, forKey: emailKey)
        defaults.set(zipcode, forKey: zipcodeKey)
        defaults.set(userType, forKey: userTypeKey)
        
    }
    
    /// Load from user defaults
    func loadUserFromDefaults() -> User? {
        var loadedUser: User?
        
        let defaults = UserDefaults.standard
        
        guard let fullname = defaults.object(forKey: fullnameKey) as? String,
        let email = defaults.object(forKey: emailKey) as? String,
        let userType = defaults.object(forKey: userTypeKey) as? String,
            let zipcode = defaults.object(forKey: zipcodeKey) as? String else {return nil}
        
        let user = User(fullname: fullname, email: email, zipcode: zipcode, userType: "\(userType)")
        loadedUser = user

        return loadedUser
    }
}

















