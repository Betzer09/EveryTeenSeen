//
//  JoinViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/6/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
    }
    
    
}
