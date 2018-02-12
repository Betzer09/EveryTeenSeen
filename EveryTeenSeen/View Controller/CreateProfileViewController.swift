//
//  CreateProfileViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/6/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var adminPasswordLabel: UILabel!
    
    
    // MARK: - Properties
    var userType: UserType?
    var userZipcode: String?
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Actions
    @IBAction func joinCauseButtonPressed(_ sender: Any) {
        self.createFirebaseAuthUser { (success) in
            if success {
                self.createUserProfile()
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    // MARK: - Set Up UI
    func setUpView() {
        guard let userType = userType else {return}
        if userType == .joinCause {
            adminPasswordTextField.isHidden = true
            adminPasswordLabel.isHidden = true
        }
        guard let userZipcode = userZipcode else {return}
        self.userZipcode = userZipcode
    }
    
    // MARK: - Create Firebase Auth User
    private func createFirebaseAuthUser(completion: @escaping (_ success: Bool) -> Void) {
        
        guard let email = emailTextField.text,
            let confirmedEmail = confirmEmailTextField.text, let password = passwordTextField.text,
            let confirmedPassword = confirmPasswordTextField.text,
            !password.isEmpty, !confirmedPassword.isEmpty, !email.isEmpty, !confirmedEmail.isEmpty else {
                
                // Inform users to fill in all the fields
                presentSimpleAlert(viewController: self, title: "Fill In all Fields", message: "")
                completion(false)
                return
        }
        
        if email.lowercased() != confirmedEmail.lowercased() {
            presentSimpleAlert(viewController: self, title: "Email's Don't match!", message: "")
            completion(false)
            return
        }
        
        // Check and make sure the passwords match
        if password != confirmedPassword {
            // Passwords don't match
            presentSimpleAlert(viewController: self, title: "Passowrds do not match!", message: "")
            passwordTextField.text = ""
            confirmPasswordTextField.text = ""
            completion(false)
        } else {
            
            // Check user type
            guard let userType = userType, let adminPass = adminPasswordTextField.text else {
                completion(false)
                return
            }
            
            switch userType {
            case .joinCause:
                UserController.shared.createAuthUser(email: email.lowercased() , pass: password)
                completion(true)
            case .leadCause:
                if adminPass != "ETSMovementUtah2018" {
                    completion(false)
                    presentSimpleAlert(viewController: self, title: "Incorrect Admin Passowrd!", message: "")
                } else {
                    UserController.shared.createAuthUser(email: email.lowercased() , pass: password)
                    completion(true)
                }
            }
        }
    }
    
    // MARK: - Create User Profile
    private func createUserProfile() {
        guard let fullname = fullnameTextField.text, let email = emailTextField.text,
            !fullname.isEmpty, !email.isEmpty else {
                presentSimpleAlert(viewController: self, title: "All Field Are Required", message: "")
                return
        }
        
        guard let zipcode = userZipcode else {NSLog("Error: There is no zipcode");return}
        guard let userType = userType else {NSLog("Error: There is no UserType");return}
        // Create User Profile
        UserController.shared.createUserProfile(fullname: fullname, email: email, zipcode: zipcode, userType: userType) { (success, error) in
            if let error = error {
                presentSimpleAlert(viewController: self, title: "Error", message: error.localizedDescription)
                UserController.shared.saveUserToDefaults(fullname: fullname, email: email, zipcode: zipcode, userType: userType.rawValue)
            }
        }
        
        
    }
    
}












