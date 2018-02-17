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

// MARK: - Codable Helper Functions 

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

/// Converts dictionaries to Data
func convertJsonToDataWith(json: [String: Any]) -> Data? {
    
    do {
        return try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    } catch let e {
        NSLog("Error converting json to data: \(e.localizedDescription)")
    }
    
    return nil
}

// MARK: - Date Formatter Functions

//DATE FORMATTING - Get rid of only if able to change date formatting?

/// This function takes in a date and returns a string 
func returnFormattedDateFor(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yyyy"
    let strDate = dateFormatter.string(from: date)
    return strDate
    
}

/// This takes in a string and returns a date
func returnFormattedDateFor(string: String) -> Date? {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "MMM dd, yyyy"
    
    guard let dateFromString: Date = dateFormatter.date(from: string) else {return nil}
    
    return dateFromString
}

extension Formatter {
    static let ISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}


// MARK: - Segue Functions
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


















