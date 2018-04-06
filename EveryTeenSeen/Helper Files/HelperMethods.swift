//
//  HelperMethods.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import UIKit
import MapKit

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


/// This function takes in a date and returns a string
func returnFormattedDateFor(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
    let strDate = dateFormatter.string(from: date)
    return strDate
}

/// Converts the string to a date for ordering events
func convertStringToDateWith(stringDate: String) -> Date? {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
    guard let date = dateFormatter.date(from: stringDate) else {NSLog("Error formating date to sort evetns"); return nil}
    return date
}

/// This takes in a time and returns a string
func returnFormattedTimeAsStringWith(date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h: mm a"
    
    let strDate = dateFormatter.string(from: date)
    return strDate
}



/// This parses the json responce for the event time and location
func parseStringByCommasForDateAndLocation(string: String, completion: @escaping(_ firstWord: String, _ everythingAfterComma: String) -> Void) {
    
    let originalAddress = string
    
    let seperatedPhrases = originalAddress.components(separatedBy: ",")
    
    let firstWord = seperatedPhrases[0]
    
    let address = Array(seperatedPhrases.dropFirst())
    
    var stringPhraseArray: [String] = []
    
    for word in address {
        stringPhraseArray.append(word + ",")
    }
    let stringPhrase = String(stringPhraseArray.joined().dropLast())
    
    completion(firstWord, stringPhrase)
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

func presentUserProfile(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "UserProfile", bundle: nil)
    guard let vc = storyboard.instantiateViewController(withIdentifier: "userProfileVC") as? UserProfileViewController else {return}
    
    let navController = UINavigationController(rootViewController: vc)
    DispatchQueue.main.async {
        viewController.present(navController, animated: true, completion: nil)
    }
}

func presentCreateEventVC(viewController: UIViewController) {
    let storyboard: UIStoryboard = UIStoryboard(name: "Admin", bundle: nil)
    guard let vc = storyboard.instantiateViewController(withIdentifier: "createEventVC") as? CreateEventViewController else {return}
    
    let navController = UINavigationController(rootViewController: vc)
    DispatchQueue.main.async {
        viewController.present(navController, animated: true, completion: nil)
    }
}

// MARK: - Alert Functions
func presentLoginAlert(viewController: UIViewController) {
    let alert = UIAlertController(title: "Sign In", message: "You are in \"View Only\" mode. In order to attend a event or view your profile you must Sign In.", preferredStyle: .alert)
    
    let signInAction = UIAlertAction(title: "Sign In", style: .default) { (_) in
        UserController.shared.signUserOut(completion: { (answer, error) in
            if let error = error {
                NSLog("Error signing view only user out! \(error)")
                return
            }
            guard answer else {return}
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

/// Creates a gradient layer on a UIViewController
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

/// Creates a gradient layer on a UIView
public func createGradientLayerWith(startpointX: Double, startpointY: Double, endpointX: Double, endPointY: Double, firstRed: Double, firstGreen: Double, firstBlue: Double, firstAlpha: CGFloat, secondRed: Double, secondGreen: Double, secondBlue: Double, secondAlpha: CGFloat, view: UIView) {
    let gradientLayer = CAGradientLayer()
    
    gradientLayer.frame = view.bounds 
    gradientLayer.startPoint = CGPoint(x: startpointX, y: startpointY)
    gradientLayer.endPoint = CGPoint(x: endpointX, y: endPointY)
    
    let orange = UIColor(red: divideNumberForColorWith(number: firstRed), green: divideNumberForColorWith(number: firstGreen), blue: divideNumberForColorWith(number: firstBlue), alpha: firstAlpha)
    
    let purple = UIColor(red: divideNumberForColorWith(number: secondRed), green: divideNumberForColorWith(number: secondGreen), blue: divideNumberForColorWith(number: secondBlue), alpha: secondAlpha)
    
    gradientLayer.colors = [orange.cgColor, purple.cgColor]
    
    view.layer.insertSublayer(gradientLayer, at: 0)
}

// MARK: - Design Functions

extension CALayer {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        mask = shape
    }
    
    //https://stackoverflow.com/questions/29618760/create-a-rectangle-with-just-two-rounded-corners-in-swift
    /// Used for table view cells
    func roundCorners(corners: UIRectCorner, radius: CGFloat, viewBounds: CGRect) {
        
        let maskPath = UIBezierPath(roundedRect: viewBounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        mask = shape
    }
}

// MARK: - Image resizing

extension UIImage {
    var isPortrait:  Bool    { return size.height > size.width }
    var isLandscape: Bool    { return size.width > size.height }
    var breadth:     CGFloat { return min(size.width, size.height) }
    var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
    var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}


// MARK: - String Extension
extension String {
    var words: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter{!$0.isEmpty}
    }
}

/// Create a blur effect on a uiview
public func createBlurEffectOn(view: UIView) {
    let blurEffect = UIBlurEffect(style: .regular)
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(blurEffectView)
    view.sendSubview(toBack: blurEffectView)
    
    
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

/// Gets all buttons in a view
public func getAllButtons(view: UIView) -> [UIButton] {
    var results = [UIButton]()
    for subview in view.subviews as [UIView] {
        if let button = subview as? UIButton {
            results += [button]
        } else {
            results += getAllButtons(view: subview)
        }
    }
    return results
}

/// Configure the buttons for user interests
public func configureAllButtonsIn(view: UIView, interests: [Interest]) {
    let buttons = getAllButtons(view: view)
    
    // Make all buttons have no title
    for i in 0...buttons.count - 1 {
        DispatchQueue.main.async {
            buttons[i].setTitle("", for: .normal)
            buttons[i].layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    if interests.count != 0 {
        
        for i in 0...interests.count - 1 {
            let interestName = interests[i].name
            
            DispatchQueue.main.async {
                buttons[i].setTitle(interestName, for: .normal)
                buttons[i].layer.borderColor = UIColor.blue.cgColor
                buttons[i].layer.borderWidth = 1
                buttons[i].layer.cornerRadius = 10
            }
        }
    }
}

/// This is used to Init an interest without saving it into the context
 func configureAllButtonsIn(view: UIView, interests: [OtherInterest]) {
    let buttons = getAllButtons(view: view)
    
    // Make all buttons have no title
    for i in 0...buttons.count - 1 {
        DispatchQueue.main.async {
            buttons[i].setTitle("", for: .normal)
            buttons[i].layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    if interests.count != 0 {
        
        for i in 0...interests.count - 1 {
            let interestName = interests[i].name
            
            DispatchQueue.main.async {
                buttons[i].setTitle(interestName, for: .normal)
                buttons[i].layer.borderColor = UIColor.blue.cgColor
                buttons[i].layer.borderWidth = 1
                buttons[i].layer.cornerRadius = 10
            }
        }
    }
}

// MARK: - User Location Functions

/// This function is used to see if we need to update the location on the phone
func findTheDistanceWith(lat: Double, long: Double) -> Bool {

    var shouldWeUpdateDistance = false
    
    guard let savedLocation = UserLocationController.shared.fetchUserLocation() else {
        // This means we need a location for the user
        return true
    }
    
    let firstCoordinate = CLLocation(latitude: savedLocation.latitude, longitude: savedLocation.longitude)
    let secondCoordinate = CLLocation(latitude: lat, longitude: long)
    
    let distanceInMeters = firstCoordinate.distance(from: secondCoordinate)
    
    // 1609 meters is one mile 40,000 meters = 24.86 miles
    if distanceInMeters >= 40000 {
        shouldWeUpdateDistance = true
    }
    
    return shouldWeUpdateDistance
    
}
