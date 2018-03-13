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
        if #available(iOS 11.0, *) {
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            // Fallback on earlier versions
        }
        return formatter
    }()
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

// MARK: - Colors

extension UIColor {
    
    static var signInAndLoginYellowColor: UIColor {
        return UIColor(red: 255 / 255.0, green: 194 / 255.0, blue: 0, alpha: 1)
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

// MARK: - Configure Navigation
/// Configures the navigation bar to have all of the normal stuff
public func configureNavigationBar(viewController: UIViewController) {
    let hamburgerButton: UIButton = UIButton(type: .custom)
    hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
    hamburgerButton.addTarget(viewController, action: #selector(UserController.shared.configureLocaiton(viewController: viewController)), for: .touchUpInside)
    
    let profileButton: UIButton = UIButton(type: .custom)
    profileButton.setImage(#imageLiteral(resourceName: "ProfilePicture"), for: .normal)
    profileButton.addTarget(viewController, action: #selector(UserController.shared.segueToProfileView(viewController: viewController)), for: .touchUpInside)
    
    let image = #imageLiteral(resourceName: "HappyLogo")
    let happyImage: UIImageView = UIImageView(image: image)
    happyImage.contentMode = .scaleAspectFit
    
    viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
    viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    viewController.navigationItem.titleView = happyImage
    
}














