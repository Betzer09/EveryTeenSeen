//
//  JoinViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/6/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {
    
    // MARK: - Properties
    var zipcode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    
    // MARK: - Functions
    private func setUpView() {
        guard let zipcode = zipcode else {return}
        self.zipcode = zipcode
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destination = segue.destination as? CreateProfileViewController else {return}
        
        
        if segue.identifier == UserType.joinCause.rawValue {
            destination.userType = UserType.joinCause
        } else if(segue.identifier == UserType.leadCause.rawValue) {
            destination.userType = UserType.leadCause
        } else {
            destination.userType = UserType.joinCause
        }
        
        destination.userZipcode = zipcode
        
    }
    
    
}
