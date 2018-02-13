//
//  EventViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import Firebase

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    // MARK: - Properties
    
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UserController.shared.signUserOut { (success, error) in
            if let error = error {
                presentSimpleAlert(viewController: self, title: "Error logging out!", message: "Error description: \(error.localizedDescription)")
            }
            
            // If the user has succesfully logged out.
            guard success else {return}
            
            // Present the login vc
            // TODO: - Fix the way the view is presented to not have a back button
            let storyboard: UIStoryboard = UIStoryboard(name: "LoginSignUp", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as? SignInViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    
    // MARK: - TableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: - Fetch the events from firestore
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
 

}
