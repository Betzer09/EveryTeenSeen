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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var adminPasswordLabel: UILabel!
    
    
    // MARK: - Properties
    var userType: UserType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: - Methods
    func setUpView() {
        guard let userType = userType else {return}
        if userType == .joinCause {
            adminPasswordTextField.isHidden = true
            adminPasswordLabel.isHidden = true
        }
    }
    
    private func createFirebaseAuthUser() {
        guard let email = emailTextField.text, let password = passwordTextField.text,
            let confirmedPassword = confirmPasswordTextField.text,
            !password.isEmpty, !confirmedPassword.isEmpty, !email.isEmpty else {
                
                // Inform users to fill in all the fields
                presentSimpleAlert(viewController: self, title: "Fill In all Fields", message: "")
                return
        }
        
        // Check and make sure the passwords match
        if password != confirmedPassword {
            // Passwords don't match
            presentSimpleAlert(viewController: self, title: "Passowrds do not match!", message: "")
        } else {
            
            // Check user type
            guard let userType = userType, let adminPass = adminPasswordTextField.text else {return}
            
            switch userType {
            case .joinCause:
                UserController.shared.createAuthUser(email: email , pass: password)
            case .leadCause:
                if adminPass != "ETSMovementUtah2018" {
                    presentSimpleAlert(viewController: self, title: "Incorrect Admin Passowrd!", message: "")
                } else {
                    UserController.shared.createAuthUser(email: email , pass: password)
                }
            }
            print("Succesfully created user")
        }
    }

}












