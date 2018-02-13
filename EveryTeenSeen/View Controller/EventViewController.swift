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
    
    
    // MARK: - View LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        
        guard let user = UserController.shared.loadUserFromDefaults()  else {return}
        presentSimpleAlert(viewController: self, title: "Welcome!", message: "\(user.fullname), \(user.email)")
        
    }
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        confirmLogoutAlert { (responce) in
            guard responce else {return}
            UserController.shared.signUserOut { (success, error) in
                if let error = error {
                    presentSimpleAlert(viewController: self, title: "Error logging out!", message: "Error description: \(error.localizedDescription)")
                }
                
                // If the user has succesfully logged out.
                guard success else {return}
                
                // Present the login vc
                presentLogoutAndSignUpPage(viewController: self)
                
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: - Functions
    
    /// This checks to make sure the user wants to logout
    private func confirmLogoutAlert(completion: @escaping(_ success: Bool) -> Void) {
        
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay, Log Me Out", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
 

}








