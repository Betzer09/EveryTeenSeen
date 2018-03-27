//
//  UpdateUserProfileViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/26/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class UpdateUserProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameTextfield: UITextField!
    @IBOutlet weak var maxLabelTextField: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var areYouAnAdminLabel: UILabel!
    @IBOutlet weak var activateAdminAccountButton: UIButton!
    
    
    // Admin Group View Outlets
    @IBOutlet weak var activateAdminGroupView: UIView!
    @IBOutlet weak var adminPasswordTextfield: UITextField!
    @IBOutlet weak var incorrectPasswordMessage: UILabel!
    
    // Success Group view
    @IBOutlet weak var successGroupView: UIView!
    
    
    // MARK: - Properties
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func activateAdminAccountButtonPressed(_ sender: Any) {
        self.activateAdminGroupView.isHidden = false
        activateAdminAccountButton.isHidden = true
        areYouAnAdminLabel.isHidden = true
        incorrectPasswordMessage.isHidden = true
    }
    
    @IBAction func dismissActivateAdminGroupButtonPressed(_ sender: Any) {
        self.activateAdminGroupView.isHidden = true
        areYouAnAdminLabel.isHidden = false
        activateAdminAccountButton.isHidden = false
    }
    
    @IBAction func dismissSuccessAdminView(_ sender: Any) {
        presentAdminTabBarVC(viewController: self)
    }
    
    
    @IBAction func sumbitAdminPasswordButtonPressed(_ sender: Any) {
        guard let password = adminPasswordTextfield.text else {return}
        
        UserController.shared.confirmAdminPasswordWith(password: password ) { (success) in
            if success {
                self.successGroupView.isHidden = false
            } else {
              self.incorrectPasswordMessage.isHidden = false
            }
        }
    }
    
    @IBAction func sliderValuedChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.maxLabelTextField.text = "\(Int(sender.value)) mi"
        }
    }
    
    // MARK: - Functions
    func setUpView() {
        adminPasswordTextfield.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        guard let user = UserController.shared.loadUserProfile() else {return}
        fullnameTextfield.text = user.fullname
        distanceSlider.setValue(Float(user.eventDistance), animated: false)
        maxLabelTextField.text = "\(user.eventDistance) mi"
        
        if user.usertype == UserType.leadCause.rawValue {
            areYouAnAdminLabel.text = "You're An Admin"
            activateAdminAccountButton.isHidden = true
        }
        
        // Set up the pop views
        activateAdminGroupView.layer.cornerRadius = 15
        successGroupView.layer.cornerRadius = 15
        
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension UpdateUserProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let password = adminPasswordTextfield.text else {return false}
        
        UserController.shared.confirmAdminPasswordWith(password: password ) { (success) in
            if success {
                self.successGroupView.isHidden = false
            } else {
                self.incorrectPasswordMessage.isHidden = false
            }
        }
        
        return true
    }
    
}






