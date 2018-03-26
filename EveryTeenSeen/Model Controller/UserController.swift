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
import CoreData

class UserController {
    
    static let shared = UserController()
    let firebaseManger = FirebaseManager()
    
    // MARK: - Keys
    private let fullnameKey = "fullname"
    private let emailKey = "email"
    private let zipcodeKey = "zipcode"
    private let userTypeKey = "user_type"
    private let userDistanceKey = "user_distance"
    
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
    func createUserProfile(fullname: String, email: String, zipcode: String, usertype: UserType, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) ) {
        let userDb = Firestore.firestore()
        
        // Create a user
        let newUser = User(email: email, fullname: fullname, usertype: usertype.rawValue, zipcode: zipcode, eventDistance: 25)
        
        userDb.collection("users").document("\(email)").setData(newUser.dictionaryRepresentation)
        print("Succesfully Created User")
        completion(true, nil)
    }
    
    // MARK: - Fetch methods
    func fetchUserInfoFromFirebaseWith(email: String, completion: @escaping ((_ user: User?, _ error: Error?) -> Void) = {_,_  in} ) {
        firebaseManger.fetchUserFromFirebaseWith(email: email) { (user, error) in
            if let error = error {
                completion(nil, error)
            }
            guard let user = user else {NSLog("Error: There is no user!"); completion(nil, nil); return}
            self.saveUserToCoreData(email: user.email, fullname: user.fullname, usertype: user.usertype, zipcode: user.zipcode, distance: user.eventDistance)
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
            guard let user = self.loadUserProfile() else {return}
            self.remove(user: user)
            
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
}

// MARK: - Coredata Functions
extension UserController {
    
    // Saves the user to CoreData
    func saveUserToCoreData(email: String, fullname: String, usertype: String, zipcode: String, distance: Int) {
        User(email: email, fullname: fullname, usertype: usertype, zipcode: zipcode, eventDistance: distance)
        saveToPersistentStore()
    }
    
    // Updates the User In CoreData
    func updateUserInCoredata(user: User, email: String, fullname: String, usertype: String, zipcode: String, profileImageStringURL: String, eventDistance: Int) {
        user.email = email
        user.fullname = fullname
        user.usertype = usertype
        user.zipcode = zipcode
        user.profileImageURLString = profileImageStringURL
        user.eventDistance = eventDistance
        user.lastUpdate = Date()
        saveToPersistentStore()
    }
    
    /// Removes Users profile from CoreData
    func remove(user: User) {
        guard let moc = user.managedObjectContext else {return} 
        moc.delete(user)
        saveToPersistentStore()
    }
    
    /// Loads user profiel from CoreDate
    func loadUserProfile() -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        guard let user = try? CoreDataStack.context.fetch(request).first else {return nil}
        return user
    }
    
    func saveToPersistentStore() {
        let moc = CoreDataStack.context
        
        do {
            try moc.save()
            NSLog("Saves user Succesfully")
        } catch let error {
            NSLog("There was a problem saving the user to persitent store: \(error) in function \(#function)")
        }
    }
}






