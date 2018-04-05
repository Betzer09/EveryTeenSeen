//
//  SignInViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

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
    
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    
    // Keyboard Properties
    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    
    // MARK: - View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAllTextfields()
        configureKeyboardNotifications()
        loginIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    // MARK: - Log User In
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        guard let email = emailTextField.text, let password = passwordTextField.text,
            !email.isEmpty, !password.isEmpty else {
                presentSimpleAlert(viewController: self, title: "Fileds are blank!", message: "All fileds must filled in!")
                return
        }
        
        self.showIndicator()
        UserController.shared.signUserInWith(email: email, password: password) { (success, error) in
            if let error = error {
                self.loginIndicator.stopAnimating()
                presentSimpleAlert(viewController: self, title: "There was a problem signing in.", message:" \(error.localizedDescription)")
                self.hideIndicator()
                return
            }
            
            // The success is true
            guard success else { self.hideIndicator() ;return}
            
            UserController.shared.fetchUserInfoFromFirebaseWith(email: email, completion: { (user, error) in
                // If there is a user sign in and fetch the info and save it to the phone
                guard let user = user else {
                    NSLog("Error There is no user for email: \(email) in function: \(#function)")
                    return
                }
                
                UserController.shared.fetchProfilePicture()
                
                self.hideIndicator()
                // Check for the kind of user
                if user.usertype == UserType.leadCause.rawValue {
                    self.requestNotificationPermission()
                    presentAdminTabBarVC(viewController: self)
                } else {
                    self.requestNotificationPermission()
                    presentEventsTabBarVC(viewController: self)
                }
                
            })
        }
    }
    
    // MARK: - Sign Up
    @IBAction func SignUpButtonPressed(_ sender: Any) {
        self.showIndicator()
        self.createFirebaseAuthUser { (success) in
            if success {
                self.createUserProfile()
                self.hideIndicator()
                self.requestNotificationPermission()
                presentEventsTabBarVC(viewController: self)
            } else {
                self.hideIndicator()
            }
        }
    }
    
    // MARK: - Sign In Toggle
    @IBAction func signUpToggleButtonPressed(_ sender: Any) {
        self.setUpSignInView()
        textFieldBeingEdited = confirmPasswordTextField
        self.dismissKeyboard()
    }
    
    @IBAction func loginToggleButtonPressed(_ sender: Any) {
        self.setUpLoginView()
        textFieldBeingEdited = passwordTextField
        self.dismissKeyboard()
    }
    
    @IBAction func skipToEventsButtonPressed(_ sender: Any) {
        UserController.shared.signUserInWith(email: "vieweventspage@gmail.com", password: "Krook123!") { (success, error) in
            if let error = error {
                NSLog("Error login user in: \(error)")
                presentSimpleAlert(viewController: self, title: "Something is going wrong and we will to fix this soon!", message: "")
            }
            guard success else {return}
            presentEventsTabBarVC(viewController: self)
        }
    }
    
    
    // MARK: - View Functions
    private func setupView() {
        createGradientLayerWith(startpointX: 0.5, startpointY: 0.3, endpointX: 0.5, endPointY: 2, firstRed: 226, firstGreen: 206, firstBlue: 244, firstAlpha: 1, secondRed: 131, secondGreen: 0, secondBlue: 252, secondAlpha: 0.25, viewController: self)
        configureButtonWith(button: signUpToggleButton)
        configureButtonWith(button: loginToggleButton)
        configureButtonWith(button: skipToEventsButton)
        
        logUserInButton.layer.cornerRadius = 15
        signUserUpAndCreateAccountButton.layer.cornerRadius = 15
        
        self.hideIndicator()
        textFieldBeingEdited = confirmPasswordTextField
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
    
    private func showIndicator() {
        loginIndicator.startAnimating()
        loginIndicator.isHidden = false
    }
    
    private func hideIndicator() {
        loginIndicator.stopAnimating()
        loginIndicator.isHidden = true
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
        
        if emailTextField.text?.last == " " {
            print("There is a space at the end of the email account")
            guard let text = emailTextField.text?.dropLast() else {return}
            emailTextField.text = String(describing: text)
        }
        if confirmEmailTextField.text?.last == " " {
            print("There is a space at the end of the email account")
            guard let text = confirmEmailTextField.text?.dropLast() else {return}
            confirmEmailTextField.text = String(describing: text)
        }
        
        guard let email = emailTextField.text?.lowercased(),
            let confirmedEmail = confirmEmailTextField.text?.lowercased(), let password = passwordTextField.text,
            let confirmedPassword = confirmPasswordTextField.text,
            !password.isEmpty, !confirmedPassword.isEmpty, !email.isEmpty, !confirmedEmail.isEmpty else {
                
                // Inform users to fill in all the fields
                presentSimpleAlert(viewController: self, title: "All of the fields are required!", message: "")
                completion(false)
                return
        }
        
        if email.lowercased() != confirmedEmail.lowercased() {
            presentSimpleAlert(viewController: self, title: "Email's Don't match! Check for a space at the end.", message: "")
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
                presentSimpleAlert(viewController: self, title: "Password Strength Is Weak!", message: "Password must contain a capital letter and 1 special charctor!")
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
        
        guard let zipcode = UserLocationController.shared.fetchUserLocation()?.zipcode else {NSLog("Error Creating User: There is no zipcode");return}
        
        CityController.shared.fetchCityWith(zipcode: zipcode, completion: { (city) in
            CityController.shared.postCityToFirebaseWith(city: city.cityName, zipcode: city.zipcode, state: city.state)
            
            // Create User Profile
            UserController.shared.createUserProfile(fullname: fullname, email: email, zipcode: "\(zipcode), \(city.cityName), \(city.state)", usertype: UserType.joinCause) { (success, error) in
                if let error = error {
                    presentSimpleAlert(viewController: self, title: "Error", message: error.localizedDescription)
                }
                
                // Save the data to the phone
                UserController.shared.saveUserToCoreData(email: email, fullname: fullname, usertype: UserType.joinCause.rawValue, zipcode: "\(zipcode), \(city.cityName), \(city.state)" , distance: 25)
            }
        })
        
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

// MARK: - Keyboard Functions
extension SignInViewController: UITextFieldDelegate {
    
    // Notificaitons
    func configureKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Makes it so the keyboard disappers
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    /// This returns the yShift for a TextField
    private func yShiftWhenKeyboardAppearsFor(textField: UITextField, keyboardHeight: CGFloat, nextY: CGFloat) -> CGFloat {
        
        let textFieldOrigin = self.view.convert(textField.frame, from: textField.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textField.frame.size.height
        
        // This is the y point that the textField's bottom can be at before it gets covered by the keyboard
        let maximumY = self.view.frame.height - keyboardHeight
        
        if textFieldBottomY > maximumY {
            // This makes the view shift the right amount to have the text field being edited 130 points above the keyboard if it would have been covered by the keyboard.
            return textFieldBottomY - maximumY + 130
        } else {
            // It would go off the screen if moved, and it won't be obscured by the keyboard.
            return logUserInButton.bounds.height + 10
        }
    }
    
    // Objective - C Functions
    @objc func keyboardWillShow(notification: NSNotification) {
        
        var keyboardSize: CGRect = .zero
        
        if let keyboardRect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect, keyboardRect.height != 0 {
            keyboardSize = keyboardRect
        } else if let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardSize = keyboardRect
        }
        
        if let textField = textFieldBeingEdited {
            if self.view.frame.origin.y == 0 {
                
                let yShift = yShiftWhenKeyboardAppearsFor(textField: textField, keyboardHeight: keyboardSize.height, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension SignInViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification.request.content.body
        
        print(notification)
        completionHandler()
    }
    
    // iOS 10 support
    func requestNotificationPermission() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}






