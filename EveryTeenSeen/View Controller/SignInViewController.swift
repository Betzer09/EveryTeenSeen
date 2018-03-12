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
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var signUpToggleButton: UIButton!
    @IBOutlet weak var loginToggleButton: UIButton!
    @IBOutlet weak var signUserUpAndCreateAccountButton: UIButton!
    @IBOutlet weak var skipToEventsButton: UIButton!
    @IBOutlet weak var logUserInButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    
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
    
    // MARK: - Log User In
    @IBAction func loginButtonPressed(_ sender: Any) {
        
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
    
    // MARK: - Sign Up
    @IBAction func SignUpButtonPressed(_ sender: Any) {
        self.createFirebaseAuthUser { (success) in
            if success {
                self.createUserProfile()
                
                guard let userType = UserController.shared.loadUserFromDefaults()?.userType else {NSLog("Error there is no usertype!"); return}
                
                if userType == UserType.leadCause.rawValue {
                    presentAdminTabBarVC(viewController: self)
                    print("User Type: Admin")
                } else {
                    presentEventsTabBarVC(viewController: self)
                    print("User Type: Normal")
                }
                
                
            }
        }
    }
    
    // MARK: - Sign In Toggle
    @IBAction func signUpToggleButtonPressed(_ sender: Any) {
        self.setUpSignInView()
    }
    
    @IBAction func loginToggleButtonPressed(_ sender: Any) {
        self.setUpLoginView()
    }
    
    @IBAction func skipToEventsButtonPressed(_ sender: Any) {
        presentSimpleAlert(viewController: self, title: "Coming Soon", message: "This feature has not been set up yet!")
    }
    
    
    // MARK: - View Functions
    private func setupView() {
        createGradientLayerWith(startpointX: 0.5, startpointY: 0.3, endpointX: 0.5, endPointY: 2, firstRed: 226, firstGreen: 206, firstBlue: 244, firstAlpha: 1, secondRed: 131, secondGreen: 0, secondBlue: 252, secondAlpha: 0.25, viewController: self)
        configureButtonWith(button: signUpToggleButton)
        configureButtonWith(button: loginToggleButton)
        configureButtonWith(button: skipToEventsButton)
        
        logUserInButton.layer.cornerRadius = 15
        signUserUpAndCreateAccountButton.layer.cornerRadius = 15
        
        
        
    }
    
    private func setUpLoginView() {
        self.signUserUpAndCreateAccountButton.isHidden = true
        
        self.confirmPasswordTextField.isHidden = true
        self.confirmEmailTextField.isHidden = true
        self.fullnameTextField.isHidden = true
        
        loginStackView.removeArrangedSubview(self.confirmPasswordTextField)
        loginStackView.removeArrangedSubview(self.confirmEmailTextField)
        loginStackView.removeArrangedSubview(self.fullnameTextField)
        
        self.logUserInButton.isHidden = false
        
        loginToggleButton.setTitleColor(UIColor.signInAndLoginYellowColor, for: .normal)
        signUpToggleButton.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    private func setUpSignInView() {
        self.signUserUpAndCreateAccountButton.isHidden = false
        
        self.confirmPasswordTextField.isHidden = false
        self.confirmEmailTextField.isHidden = false
        self.fullnameTextField.isHidden = false
        
        loginStackView.insertArrangedSubview(self.fullnameTextField, at: 0)
        loginStackView.insertArrangedSubview(self.confirmEmailTextField, at: 2)
        loginStackView.insertArrangedSubview(self.confirmPasswordTextField, at: 4)
        
        self.logUserInButton.isHidden = true
        
        loginToggleButton.setTitleColor(UIColor.white, for: .normal)
        signUpToggleButton.setTitleColor(UIColor.signInAndLoginYellowColor, for: .normal)
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

// MARK: - User Creatation and Sign In
extension SignInViewController {
    
    
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
            
            // Before creating a user check password strength
            guard isPasswordStrongEnough else {
                presentSimpleAlert(viewController: self, title: "Password Strength Weak!", message: "Password must contain a capital letter and 1 special charctor!")
                completion(false)
                return
            }
            
            UserController.shared.createAuthUser(email: email.lowercased(), pass: password, completion: { (success) in
                guard success else {return}
                completion(true)
            })
        }
    }
    
    // MARK: - Create User Profile
    /// This creates a profile for the user in firebase
    private func createUserProfile() {
        guard let fullname = fullnameTextField.text, let email = emailTextField.text?.lowercased(),
            !fullname.isEmpty, !email.isEmpty else {
                presentSimpleAlert(viewController: self, title: "All Field Are Required", message: "")
                return
        }
        
        guard let zipcode = UserLocationController.shared.fetchUserLocation()?.zipcode else {NSLog("Error: There is no zipcode");return}
        // Create User Profile
        UserController.shared.createUserProfile(fullname: fullname, email: email, zipcode: zipcode, userType: UserType.joinCause) { (success, error) in
            if let error = error {
                presentSimpleAlert(viewController: self, title: "Error", message: error.localizedDescription)
            }
            
            // Save the data to the phone
            UserController.shared.saveUserToDefaults(fullname: fullname, email: email, zipcode: zipcode, userType: UserType.joinCause.rawValue)
            
            CityController.shared.fetchCityWith(zipcode: zipcode, completion: { (city) in
                CityController.shared.postCityToFirebaseWith(city: city.city, zipcode: city.zipcode, state: city.state)
            })
        }
    }
    
    /// Checks password strength passwords must contain a capital letter, and 1 special charactor
    private func checkPasswordStrength(password1: String) -> Bool {
        
        // TODO: - Make special charactors not count as capital letters
        
        // Check password strength
        let specialCharactores = [ "~", "!", "@", "#", "$", "%", "^", "&", "*", "_", "-", "+", "=", "`", "|", "(", ")","{", "}", "[", "]", ":", ";", "'", "<", ">", ",", ".", "?", "/" ]
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






