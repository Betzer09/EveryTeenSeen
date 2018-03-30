//
//  UserController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
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
    
    func updateUserProfileWith(user: User, fullname: String, profileImageURL: String, maxDistance: Int64, usertype: UserType.RawValue) {
        let userDb = Firestore.firestore()
        
        // Update the user in Coredata
        guard let profileImageURL = user.profileImageURLString,
            let email = user.email,
            let fullname = user.fullname,
            let usertype = user.usertype,
            let zipcode = user.zipcode else {NSLog("Error updating user in function \(#function)"); return}
        
        guard let loadedUser = UserController.shared.loadUserProfile() else {return}
        
        updateUserInCoredata(user: loadedUser, email: email, fullname: fullname, usertype: usertype, zipcode: zipcode, profileImageStringURL: profileImageURL, eventDistance: user.eventDistance)
        
        // Update the user in firebase
        userDb.collection("users").document(email).setData(user.dictionaryRepresentation)
    }
    
    /// Checks to see if there is a current user
    func checkIfThereIsACurrentUser() -> Bool {
        if Auth.auth().currentUser == nil {
            return false
        } else {
            return true
        }
    }
        
    // MARK: - Fetch methods
    func fetchUserInfoFromFirebaseWith(email: String, completion: @escaping ((_ user: User?, _ error: Error?) -> Void) = {_,_  in} ) {
        firebaseManger.fetchUserFromFirebaseWith(email: email) { (user, error) in
            if let error = error {
                completion(nil, error)
            }
            guard let user = user,
                let fullname = user.fullname,
                let usertype = user.usertype,
                let profileImageURLString = user.profileImageURLString else {NSLog("Error: There is no user!"); completion(nil, nil); return}
            
            self.updateUserProfileWith(user: user, fullname: fullname, profileImageURL: profileImageURLString, maxDistance: user.eventDistance, usertype: usertype)
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
    
    // MARK: - Confirm password
    /// Fetches the admin password from firebase to confirm it
    func confirmAdminPasswordWith(password: String, completion: @escaping(_ success: Bool) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("admin_password").document("passwordID").getDocument { (snapshot, error) in
            if let error = error {
                NSLog("Error fetching the password: \(error.localizedDescription)")
            }
            
            guard let jsonData = snapshot?.data(), let data = convertJsonToDataWith(json: jsonData) else {return}
            
            let adminPassword = try? JSONDecoder().decode(AdminPassword.self, from: data)
            guard let firebasePassword = adminPassword?.password else {return}
            
            if firebasePassword == password {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

// MARK: - Coredata Functions
extension UserController {
    
    // Saves the user to CoreData
    func saveUserToCoreData(email: String, fullname: String, usertype: String, zipcode: String, distance: Int64) {
        User(email: email, fullname: fullname, usertype: usertype, zipcode: zipcode, eventDistance: distance)
        saveToPersistentStore()
    }
    
    // Updates the User In CoreData
    func updateUserInCoredata(user: User, email: String, fullname: String, usertype: String, zipcode: String, profileImageStringURL: String, eventDistance: Int64) {
        
        user.email = email
        user.fullname = fullname
        user.zipcode = zipcode
        user.profileImageURLString = profileImageStringURL
        user.eventDistance = eventDistance
        user.usertype = usertype
        user.lastUpdate = Date()
        
        do {
            try user.managedObjectContext?.save()
        } catch {
            NSLog("User Failed to update in function: \(#function)")
        }
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
    
    // Deletes all the data for Users
    func deleteAllUserData() {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        let context = CoreDataStack.context
        
        guard let users = try? context.fetch(fetchRequest) else {
            NSLog("Error clearing all user data from Coredata! \(#function)")
            return
        }
        
        for user in users {
            context.delete(user)
        }
        
        do {
           try context.save()
        } catch let e {
            NSLog("Error saving deleted users context: \(e.localizedDescription) in function: \(#function)")
        }
        
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






