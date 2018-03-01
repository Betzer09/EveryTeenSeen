//
//  SignInViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: - Properties
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Actions
    @IBAction func signInButtonPressed(_ sender: Any) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text,
            !email.isEmpty, !password.isEmpty else {
                presentSimpleAlert(viewController: self, title: "Error", message: "All fileds must filled")
                return
        }
        
        UserController.shared.signUserInWith(email: email, password: password) { (success, error) in
            if let error = error {
                presentSimpleAlert(viewController: self, title: "There was a problem signing in.", message:" \(error.localizedDescription)")
            }
            
            // The success is true
            guard success else {return}
            
            UserController.shared.fetchUserInfoFromFirebaseWith(email: email, completion: { (user, error) in
                // If there is a user sign in and fetch the info and save it to the phone
                guard let user = user else {
                    NSLog("Error There is no user for email: \(email) in function: \(#function)")
                    return
                }
                
                // Check for the kind of user
                if user.userType == UserType.leadCause.rawValue {
                    presentAdminTabBarVC(viewController: self)
                } else {
                    presentEventsTabBarVC(viewController: self)
                }
                
            })
        }
    }
    
    // MARK: - FireBase Methods
    private func checkForCurrentUser() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            presentSimpleAlert(viewController: self, title: "No User", message: "There is not user currently signed in.")
            return false
        }
    }
}
