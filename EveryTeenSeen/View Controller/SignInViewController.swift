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
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUserUpAndCreateAccountButton: UIButton!
    @IBOutlet weak var skipToEventsButton: UIButton!
    
    // MARK: - Properties
    
    // MARK: - View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAllTextfields()
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
    
    // MARK: - Sign In Toggle
    @IBAction func signUpToggleButtonPressed(_ sender: Any) {
    }
    
    @IBAction func loginToggleButtonPressed(_ sender: Any) {
    }
    
    @IBAction func skipToEventsButtonPressed(_ sender: Any) {
    }
    
    
    // MARK: - Functions
    private func setupView() {
        createGradientLayerWith(startpointX: 0.5, startpointY: 0.3, endpointX: 0.5, endPointY: 2, firstRed: 226, firstGreen: 206, firstBlue: 244, firstAlpha: 1, secondRed: 131, secondGreen: 0, secondBlue: 252, secondAlpha: 0.25, viewController: self)
        configureButtonWith(button: signUpButton)
        configureButtonWith(button: loginButton)
        configureButtonWith(button: skipToEventsButton)
        signUserUpAndCreateAccountButton.layer.cornerRadius = 15
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

// MARK: - TextField Designs
extension SignInViewController {
    // Gets all the textfields in the view
    private func getTextfield(view: UIView) -> [UITextField] {
        var results = [UITextField]()
        for subview in view.subviews as [UIView] {
            if let textField = subview as? UITextField {
                results += [textField]
            } else {
                results += getTextfield(view: subview)
            }
        }
        return results
    }
    
    private func configureAllTextfields() {
        let allTextFields = getTextfield(view: self.view)
        
        for txtField in allTextFields {
            txtField.layer.cornerRadius = 10
            txtField.attributedPlaceholder = NSAttributedString(string: txtField.placeholder ?? "", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            txtField.layer.borderColor = UIColor.white.cgColor
            txtField.layer.borderWidth = 1.0
        }
    }
}






