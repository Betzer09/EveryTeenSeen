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
        self.checkForCurrentUser()
    }
    
    
    // MARK: - Actions
    @IBAction func signInButtonPressed(_ sender: Any) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text,
            !email.isEmpty, !password.isEmpty else {return}
        
        UserController.shared.signUserInWith(email: email, password: password) { (success, error) in
            if let error = error {
                presentSimpleAlert(viewController: self, title: "There was a problem signing in.", message:" \(error.localizedDescription)")
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "eventsVC") as? EventViewController else {return}
            self.present(vc, animated: true, completion: nil)
            
            
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














