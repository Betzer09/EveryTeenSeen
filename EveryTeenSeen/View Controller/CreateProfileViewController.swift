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
                
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "MainUserTab")
                
                self.present(vc, animated: true, completion: nil)

            }
        }
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
            
            let isPasswordStrongEnough = checkPasswordStrength(password1: password)
            
            guard isPasswordStrongEnough else {
                presentSimpleAlert(viewController: self, title: "Password Strength Weak!", message: "Password must contain a capital letter and 1 special charctor!")
                completion(false)
                return
            }
            
            // Check user type
            guard let userType = userType, let adminPass = adminPasswordTextField.text else {
                completion(false)
                return
            }
            
            // Before creating a user check password strength
            
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
            }
            
            // Save the data to the phone
            UserController.shared.saveUserToDefaults(fullname: fullname, email: email, zipcode: zipcode, userType: userType.rawValue)
        }
        
        
    }
    
    // MARK: - Check password
    /// Checks password strength passwords must contain a capital letter, and 1 special charactor
    private func checkPasswordStrength(password1: String) -> Bool {
        
        // TODO: - Make special charactors not count as capital letters
        
        // Check password strength
        let specialCharactores = [ "~", "!", "@", "#", "$", "%", "^", "&", "*", "_", "-", "+", "=", "`", "|", "(", ")",
                                   "{", "}", "[", "]", ":", ";", "'", "<", ">", ",", ".", "?", "/" ]
        var specialCharactorCount = 0
        var capitalCharactorCount = 0
        var strength = false
        
        // Has to have one symbole
        for char in specialCharactores {
            if password1.contains(char) {
                specialCharactorCount += 1
            }
        }
        
        // must have one capital letter
        for char in password1 {
            
            // Take the charactor and uppercase it then check if they are the same
            let stringCharUppercased = String(char).uppercased()
            let stringChar = String(char)
            
            if stringChar == stringCharUppercased {
                // this means there is a capital letter
                capitalCharactorCount += 1
            }
        }
        
        
        // has to have 6 charactors
        if password1.count >= 6 && specialCharactorCount >= 1 && capitalCharactorCount >= 1 {
            strength = true
            print("password is strong enough")
        } else {
            print("password isn't strong enough")
        }
        
        return strength
    }
}












