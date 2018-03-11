//
//  GetStartedViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import MapKit

class GetStartedViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var viewBehindTheButton: UIView!
    @IBOutlet weak var backgroundLayer: UIView!
    @IBOutlet weak var locationServicesView: UIView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var acceptLocationButton: UIButton!
    
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    let locationManager = CLLocationManager()
    
    // MARK: - View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        getStartedButton.layer.cornerRadius = 25
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createGradientLayer()
        self.setupView()
    }
    
    // MARK: - Actions
    
    @IBAction func acceptLocationServicesButtonPressed(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // Set a timer that way we know it's saved
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            guard let zip = UserLocationController.shared.fetchUserLocation()?.zipcode else {return}
            
            CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                guard CityController.shared.verifyLocationFor(city: city) else {
                    presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!")
                    return
                }
                presentLogoutAndSignUpPage(viewController: self)
            })
        }
    }
    
    @IBAction func enterzipCodeButtonPressed(_ sender: Any) {
        self.presentLocationServicesAlert()
    }
    
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        locationServicesView.isHidden = false
    }
    
    
    // MARK: - Functions
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: -0.25, y: 0.75)
        
        let lightBlue = UIColor(red: divideNumberForColorWith(number: 76), green: divideNumberForColorWith(number: 159), blue: divideNumberForColorWith(number: 255), alpha: 1.0)
        let purple = UIColor(red: divideNumberForColorWith(number: 146), green: divideNumberForColorWith(number: 29), blue: divideNumberForColorWith(number: 255), alpha: 0.5)
        
        gradientLayer.colors = [lightBlue.cgColor, purple.cgColor]
        
        self.backgroundLayer.layer.addSublayer(gradientLayer)
        self.view.sendSubview(toBack: backgroundLayer)
    }
    
    private func presentLocationServicesAlert() {
        var zipcodeTextField: UITextField!
        
        let alert = UIAlertController(title: "Enter Your Zipcode", message: "Every Teen Seen is a group that is growing rapidly, but we are only in a few locations.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "83274"
            textField.keyboardType = .decimalPad
            zipcodeTextField = textField
        }
        
        let verifyAction = UIAlertAction(title: "Verify", style: .default) { (_) in
            guard let zipcodeString = zipcodeTextField.text, let zipcode = Int(zipcodeString) else {return}
            CityController.shared.fetchCityWith(zipcode: "\(zipcode)", completion: { (City) in
                // Check to see if the state is correct
                guard CityController.shared.verifyLocationFor(city: City) else {
                    
                    // If the state isn't in utah alert the user
                    presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!")
                    return
                }
                // Show the login page
                presentLogoutAndSignUpPage(viewController: self)
            })
        }
        alert.addAction(verifyAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - View Configuration
    private func setupView() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        acceptLocationButton.layer.cornerRadius = 20
        locationServicesView.layer.cornerRadius = 15
    }
}


extension GetStartedViewController: CLLocationManagerDelegate {
    // Saves the location when permission is granted
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("We have permission to use the user's location")
            locationManager.requestLocation()
            
            // Check to see if we already have a location
            guard UserLocationController.shared.fetchUserLocation() == nil else {
                return
            }
            
            // If there isn't a location create and save it
            self.fetchTheUsersLocation(completion: { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                UserLocationController.shared.createLocationWith(lat: location.latitude , long: location.longitude, zip: zip)
                
                // Make sure they are allowed to create an account
                CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                    guard CityController.shared.verifyLocationFor(city: city) else {
                        presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!")
                        return
                    }
                    presentLogoutAndSignUpPage(viewController: self)
                })
            })
        }
    }
    
    // Updates the location if it changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location: \(location)")
            
            // Checks if the location should be updated
            guard findTheDistanceWith(lat: location.coordinate.latitude , long: location.coordinate.longitude) else {
                print("Location does not need updated")
                return
            }
            
            // Write a function to grab and update the user's location
            self.fetchTheUsersLocation { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                
                UserLocationController.shared.update(lat: location.latitude, long: location.longitude, zip: zip)
            }
        }
        
    }
    
    // Required function is case there is a failure.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Error with location Manager: \(error.localizedDescription)")
    }
    
    /// Fetches the users location and gets the lat long and zip and returns a UserLocation
    func fetchTheUsersLocation(completion: @escaping(_ location: UserLocation?) -> Void) {
        guard let userLocation = locationManager.location else {completion(nil); return}
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: { (placemarks, error) in
            
            if let error = error {
                NSLog("Error getting the zip code: \(error.localizedDescription) in function: \(#function) ")
            }
            
            guard let placemark = placemarks?.first, let zip = placemark.postalCode else {completion(nil); return}
            
            let lat = userLocation.coordinate.latitude
            let long = userLocation.coordinate.longitude
            
            let userLocation = UserLocation(latitude: lat, longitude: long, zip: zip)
            completion(userLocation)
            self.locationManager.stopUpdatingLocation()
            
            CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                guard CityController.shared.verifyLocationFor(city: city) else {
                    presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!")
                    return
                }
                presentLogoutAndSignUpPage(viewController: self)
            })
            
        })
    }
    
    /// This function is used to see if we need to update the location on the phone
    func findTheDistanceWith(lat: Double, long: Double) -> Bool {
        guard let savedLocation = UserLocationController.shared.fetchUserLocation() else {return false}
        
        var shouldWeUpdateDistance = false
        
        let firstCoordinate = CLLocation(latitude: savedLocation.latitude, longitude: savedLocation.longitude)
        let secondCoordinate = CLLocation(latitude: lat, longitude: long)
        
        let distanceInMeters = firstCoordinate.distance(from: secondCoordinate)
        
        // 1609 meters is one mile 40,000 meters = 24.86 miles
        if distanceInMeters >= 40000 {
            shouldWeUpdateDistance = true
        }
        
        return shouldWeUpdateDistance
        
    }
}
