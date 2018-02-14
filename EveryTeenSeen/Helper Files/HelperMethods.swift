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

// MARK: - String To Dict
///Converts json strings to dictionaries
public func convertStringToDictWith(string: String) -> [String: Any] {
    
    var dict: [String:Any]?
    
    if let data = string.data(using: String.Encoding.utf8) {
        
        do {
            dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    guard let myDictionary = dict else {return [String:Any]()}
    return myDictionary
}

func presentEventsTabBarVC(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "MainUserTab")
    
    viewController.present(vc, animated: true, completion: nil)
}

func presentLogoutAndSignUpPage(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "LoginSignUp", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "loginVC")
    
    viewController.present(vc, animated: true, completion: nil)
    
}
