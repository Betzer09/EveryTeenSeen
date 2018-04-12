//
//  AdminPasswordController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase

class AdminPasswordController {
    
    static let shared = AdminPasswordController()
    static let passswordKey: String = "adminPassword"
    
    // MARK: - Properties
    var adminPassword = ""
    
    func fetchAdminPasswordFromFirebase(competion: @escaping (_ needToSignUserOut: Bool) -> Void = {_ in}) {
        let db = Firestore.firestore()
        
        db.collection("admin_password").document("passwordID").getDocument { (snapshot, error) in
            if let error = error {
                NSLog("Error fetching the password: \(error.localizedDescription)")
            }
            
            guard let jsonData = snapshot?.data(), let data = convertJsonToDataWith(json: jsonData) else {return}
            
            let adminPassword = try? JSONDecoder().decode(AdminPassword.self, from: data)
            guard let firebasePassword = adminPassword?.password else {return}
            self.adminPassword = firebasePassword
            
            if self.loadPasswordFromDefaults() == "" {
                self.savePasswordToDefaultsWith(password: self.adminPassword)
            } else {
                if self.loadPasswordFromDefaults() != firebasePassword {
                    // Log the user out
                    guard let usertype = UserController.shared.loadUserProfile()?.usertype else {return}
                    
                    if usertype == UserType.leadCause.rawValue {
                        self.makeUserNonAdmin(completion: { (done) in
                            guard done else {return}
                            self.savePasswordToDefaultsWith(password: self.adminPassword)
                            competion(true)
                        })
                    } else {
                        competion(false)
                    }
                } else {
                    competion(false)
                }
            }
        }
    }
    
    func savePasswordToDefaultsWith(password: String) {
        let defaults = UserDefaults.standard
        defaults.set(password, forKey: AdminPasswordController.passswordKey)
    }
    
    func loadPasswordFromDefaults() -> String {
        let defaults = UserDefaults.standard
        guard let passowrd =  defaults.object(forKey: AdminPasswordController.passswordKey) as? String else {return ""}
        return passowrd
    }
    
    /// This is used to notify the user that he is no longer an admin until he gets the new password
    func makeUserNonAdmin(completion: @escaping (_ done: Bool) -> Void) {
        guard let user = UserController.shared.loadUserProfile(),
            let fullname = user.fullname,
            let profileURL = user.profileImageURLString else {return}
        
        UserController.shared.updateUserProfileWith(user: user, fullname: fullname, profileImageURL: profileURL, maxDistance: user.eventDistance, usertype: UserType.joinCause.rawValue)
        
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch let e {
            NSLog("Error make user a non admin! : \(e.localizedDescription)")
            return
        }
    }
    
}
