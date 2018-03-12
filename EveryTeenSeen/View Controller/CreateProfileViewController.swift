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
    
    
    // MARK: - Check password
}
