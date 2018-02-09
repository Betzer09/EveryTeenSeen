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
    
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
    }
    
    
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
            guard let zipcodeString = zipcodeTextField.text, let zipcode = Int(zipcodeString) else {return}
            CityController.shared.fetchCityWith(zipcode: zipcode, completion: { (City) in
                // Check to see if the state is correct
                guard CityController.shared.verifyLocationFor(city: City) else {
                    
                    // If the state isn't in utah alert the user
                    self.presentSimpleAlert(title: "Error", message: "You location is not supported yet!")
                    return
                }
                
                // show joinViewController
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "joinVC") as? JoinViewController else {return
                    
                }
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)                    
                }
                
            })
            
        }
        
        alert.addAction(verifyAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UI Functions
    
    private func setUpView() {
        
    }
    
    // MARK: - Alerts
    private func presentSimpleAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}









