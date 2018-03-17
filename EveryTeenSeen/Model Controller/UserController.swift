//
//  UserController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit

class UserController {
    
    static let shared = UserController()
    let firebaseManger = FirebaseManager()
    
    // MARK: - Keys
    private let fullnameKey = "fullname"
    private let emailKey = "email"
    private let zipcodeKey = "zipcode"
    private let userTypeKey = "user_type"
    
    /// This is the phone key that allows for push notifications
    static let phoneTokenKey = "phone_token"
    
    /// This tracks the device, it is the key to get the phone token
    private let deviceIDKey = "device_id"
    private let deviceTokensKey = "device_tokens"
    
    // MARK: - Create Auth User
    func createAuthUser(email: String, pass: String, completion: @escaping (_ success: Bool) -> Void) {
        firebaseManger.createFirebaseUserWith(email: email, password: pass) { (success) in
            guard success else {return}
            completion(true)
        }
    }
    // MARK: - Firestore Methods
    func createUserProfile(fullname: String, email: String, zipcode: String, userType: UserType, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) ) {
        let userDb = Firestore.firestore()
        
        // Create a user
        let newUser = User(fullname: fullname, email: email, zipcode: zipcode, userType: userType.rawValue)
        
        do {
            let data = try JSONEncoder().encode(newUser)
            guard let stringDict = String(data: data, encoding: .utf8) else {completion(false,nil); return}
            let jsonDict = convertStringToDictWith(string: stringDict)
            
            userDb.collection("users").document("\(email)").setData(jsonDict)
            print("Succesfully Created User")
            completion(true, nil)
            
        } catch let e {
            completion(false, e)
            print("Error Createing User")
            NSLog("Error encoding user data: \(e)")
        }
        
    }
    
    // MARK: - Fetch methods
    func fetchUserInfoFromFirebaseWith(email: String, completion: @escaping ((_ user: User?, _ error: Error?) -> Void)) {
        firebaseManger.fetchUserFromFirebaseWith(email: email) { (user, error) in
            if let error = error {
                completion(nil, error)
            }
            guard let user = user else {NSLog("Error: There is no user!"); completion(nil, nil); return}
            
            completion(user, nil)
        }
    }
    
    // MARK: - UserState methods
    func signUserInWith(email: String, password: String, completion: @escaping((_ success: Bool, _ error: Error?) -> Void)) {
        firebaseManger.signUserInWith(email: email, andPass: password) { (success, error) in
            completion(success, error)
        }
    }
    
    func signUserOut(completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        
        firebaseManger.signUserOut { (success, error) in
            if let error = error {
                completion(false, error)
            }
            
            // Checks to make sure that success is true
            guard success else {completion(false, error); return}
            
            // Sign the user out of user defaults
            self.deleteUserFromUserDefaults()
            
            completion(true,nil)
        }
    }
    
    
    /// This function is used to sign out because they need to create their own account instead of using the view only account
    func signViewOnlyUserOut(completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        firebaseManger.signUserOut { (success, error) in
            if let error = error {
                completion(false, error)
            }
            // Checks to make sure that success is true
            guard success else {completion(false, error); return}
            completion(true,nil)
        }
    }
    
    /// This checks to make sure the user wants to logout
    func confirmLogoutAlert(viewController: UIViewController, completion: @escaping(_ success: Bool) -> Void) {
        
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay, Log Me Out", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
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
    
    /// Removes the user from user defaults
    private func deleteUserFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: fullnameKey)
        defaults.removeObject(forKey: emailKey)
        defaults.removeObject(forKey: zipcodeKey)
        defaults.removeObject(forKey: userTypeKey)
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
