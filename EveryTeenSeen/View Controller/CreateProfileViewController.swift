//
//  CreateProfileViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/6/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var adminPasswordLabel: UILabel!
    
    
    // MARK: - Properties
    var userType: JoinViewController.UserType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
