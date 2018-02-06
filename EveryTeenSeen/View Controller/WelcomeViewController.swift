//
//  WelcomeViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/1/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Properties
    
    // MARK: - Actions
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        var zipcodeTextField: UITextField!
        
        let alert = UIAlertController(title: "Enter Your Zipcode", message: "Every Teen Seen is a group that is growing rapidly, but we are only in a few locations.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "83274"
            textField.keyboardType = .decimalPad
            zipcodeTextField = textField
        }
        
        let verifyAction = UIAlertAction(title: "Verify", style: .default) { (_) in
            
        }
        
    }
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    func checkZipCodeWith(zipcode: Int, completion: @escaping(City) -> Void) {
        
    }

}









