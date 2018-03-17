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

/// Converts data to string Dictionaries
func convertDataToStringDictionary(data: Data) -> String? {
    
    guard let stringDict = String(data: data, encoding: .utf8) else {return nil}
    return stringDict
    
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

// Takes in a string and returns a date 
func returnFormattedDateFor(string: String) -> String? {
    
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd hh:mm:ssZ"
    
    let dateFormatterPrint = DateFormatter()
    dateFormatterPrint.dateFormat = "MMM d, yyyy"
    
    guard let date: Date = dateFormatterGet.date(from: string) else {return nil}
    return dateFormatterPrint.string(from: date)
}

/// This takes in a time and returns a string
func returnFormattedTimeAsStringWith(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h: mm a"
    
    let strDate = dateFormatter.string(from: date)
    return strDate
}

// MARK: - Segue Functions
func presentEventsTabBarVC(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "MainUserTab")
    
    DispatchQueue.main.async {
        viewController.present(vc, animated: true, completion: nil)
    }
}

func presentLogoutAndSignUpPage(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "LoginSignUp", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "loginVC")
    
    DispatchQueue.main.async {
        viewController.present(vc, animated: true, completion: nil)        
    }
    
}

func presentAdminTabBarVC(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Admin", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "MainUserTab")
    
    DispatchQueue.main.async {
        viewController.present(vc, animated: true, completion: nil)
    }
}

// MARK: - Alert Functions
func presentLoginAlert(viewController: UIViewController) {
    let alert = UIAlertController(title: "Sign In", message: "You are in view only mode. In order to attend an event you need to create an account", preferredStyle: .alert)
    
    let signInAction = UIAlertAction(title: "Sign In", style: .default) { (_) in
        UserController.shared.signUserOut(completion: { (answer, error) in
            if let error = error {
                NSLog("Error signing view only user out! \(error)")
            }
            presentLogoutAndSignUpPage(viewController: viewController)
        })
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    
    alert.addAction(cancelAction)
    alert.addAction(signInAction)
    
    viewController.present(alert, animated: true, completion: nil)
}

// MARK: - Colors

extension UIColor {
    
    static var signInAndLoginYellowColor: UIColor {
        return UIColor(red: 255 / 255.0, green: 194 / 255.0, blue: 0, alpha: 1)
    }
    
    static var darkBlueAlertColor: UIColor{
      return UIColor(red: divideNumberForColorWith(number: 97), green: divideNumberForColorWith(number: 121), blue: divideNumberForColorWith(number: 255), alpha: 1)
    }
    
    static var lightGreyTextColor: UIColor {
        return UIColor(red: divideNumberForColorWith(number: 134), green: divideNumberForColorWith(number: 134), blue: divideNumberForColorWith(number: 134), alpha: 1)
    }
}

/// This divids the given number by 255.0 to return a cgfloat. Used For Colors
 public func divideNumberForColorWith(number: Double) -> CGFloat {
    return CGFloat(number / 255.0)
}

public func createGradientLayerWith(startpointX: Double, startpointY: Double, endpointX: Double, endPointY: Double, firstRed: Double, firstGreen: Double, firstBlue: Double, firstAlpha: CGFloat, secondRed: Double, secondGreen: Double, secondBlue: Double, secondAlpha: CGFloat, viewController: UIViewController) {
    let gradientLayer = CAGradientLayer()
    
    gradientLayer.frame = viewController.view.bounds
    gradientLayer.startPoint = CGPoint(x: startpointX, y: startpointY)
    gradientLayer.endPoint = CGPoint(x: endpointX, y: endPointY)
    
    let orange = UIColor(red: divideNumberForColorWith(number: firstRed), green: divideNumberForColorWith(number: firstGreen), blue: divideNumberForColorWith(number: firstBlue), alpha: firstAlpha)
    
    let purple = UIColor(red: divideNumberForColorWith(number: secondRed), green: divideNumberForColorWith(number: secondGreen), blue: divideNumberForColorWith(number: secondBlue), alpha: secondAlpha)
    
    gradientLayer.colors = [orange.cgColor, purple.cgColor]
    
    viewController.view.layer.insertSublayer(gradientLayer, at: 0)
}

// MARK: - Uibutton Proportions
/// This configures to the button to be proportinal on all screen sizes
public func configureButtonWith(button: UIButton) {
    button.titleLabel?.numberOfLines = 1
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    button.titleLabel?.minimumScaleFactor = 0.1
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 80)
    button.titleLabel?.lineBreakMode = .byClipping
}














