//
//  HelperMethods.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import UIKit

public func presentSimpleAlert(viewController: UIViewController, title: String, message: String) {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let dismissAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    
    alert.addAction(dismissAction)
    
    viewController.present(alert, animated: true, completion: nil)
}

func presentEventsTabBarVC(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "MainUserTab")
    
    viewController.present(vc, animated: true, completion: nil)
}


