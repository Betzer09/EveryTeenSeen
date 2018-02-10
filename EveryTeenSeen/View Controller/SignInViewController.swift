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
            
            // TODO: - Present the Sign in Page
            presentSimpleAlert(viewController: self, title: "Sucess", message: "Nice job signing in :)")
        }
    }
    
    // MARK: - FireBase Methods
    private func checkForCurrentUser() {
        if Auth.auth().currentUser != nil {
            
            // If there is a user go to get started page for now
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "getStartedVC") as? WelcomeViewController else {return}
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}














