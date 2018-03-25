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
    @IBOutlet weak var zipcodeCheckActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var viewBehindTheButton: UIView!
    @IBOutlet weak var backgroundLayer: UIView!
    @IBOutlet weak var locationServicesGroupingView: UIView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var acceptLocationButton: UIButton!
    @IBOutlet weak var enterZipcodeButton: UIButton!
    
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    let locationManager = CLLocationManager()
    var locationIsDenied: Bool? = false
    
    // MARK: - View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        self.createGradientLayer()
        self.setupView()
    }
    
    // MARK: - Actions
    
    @IBAction func acceptLocationServicesButtonPressed(_ sender: Any) {
        
        if locationIsDenied == true {
            self.informTheUserAboutLocation()
        } else {
            showActivityIndicator()
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            
            guard let zip = UserLocationController.shared.fetchUserLocation()?.zipcode else {
                NSLog("Error fetching the users zipcode")
                return
            }
            
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
        locationServicesGroupingView.isHidden = false
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
            self.showActivityIndicator()
            guard let zipcodeString = zipcodeTextField.text,
                let zipcode = Int(zipcodeString) else {return}
            
            CityController.shared.fetchCityWith(zipcode: "\(zipcode)", completion: { (City) in
                // Check to see if the state is correct
                guard CityController.shared.verifyLocationFor(city: City) else {
                    
                    // If the state isn't in utah alert the user
                    presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!")
                    self.hideActivityIndicator()
                    return
                }
                self.hideActivityIndicator()
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
        acceptLocationButton.layer.cornerRadius = 15
        locationServicesGroupingView.layer.cornerRadius = 15
        getStartedButton.layer.cornerRadius = 20
        zipcodeCheckActivityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        zipcodeCheckActivityIndicator.isHidden = true
        
//        configureButtonWith(button: getStartedButton)
//        configureButtonWith(button: acceptLocationButton)
//        configureButtonWith(button: enterZipcodeButton)
    }
    
    private func showActivityIndicator() {
        DispatchQueue.main.async {
            self.zipcodeCheckActivityIndicator.isHidden = false
            self.zipcodeCheckActivityIndicator.startAnimating()
        }
        locationServicesGroupingView.bringSubview(toFront: zipcodeCheckActivityIndicator)
    }
    
    private func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.zipcodeCheckActivityIndicator.isHidden = true
            self.zipcodeCheckActivityIndicator.stopAnimating()
        }
    }
}


// MARK: - User Location Functions
extension GetStartedViewController: CLLocationManagerDelegate {
    // Saves the location when permission is granted
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("We have permission to use the user's location")
            locationManager.requestLocation()
            locationIsDenied = false
            
            // Check to see if we already have a location
            guard UserLocationController.shared.fetchUserLocation() == nil else {
                return
            }
            
            // If there isn't a location create and save it
            self.fetchTheUsersLocation(completion: { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                // Make sure they are allowed to create an account
                
                CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                    guard CityController.shared.verifyLocationFor(city: city) else {
                        presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!"); return }
                    
                    UserLocationController.shared.createLocationWith(lat: location.latitude , long: location.longitude, zip: zip, cityName: city.city)
                    self.hideActivityIndicator()
                    presentLogoutAndSignUpPage(viewController: self)
                })
            })
        }
        
        if status == .denied {
            informTheUserAboutLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            guard findTheDistanceWith(lat: location.coordinate.latitude , long: location.coordinate.longitude) == true else {
                print("Location does not need updated")
                return
            }
            
            // Write a function to grab and update the user's location
            fetchTheUsersLocation { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                
                CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                    guard let location = UserLocationController.shared.fetchUserLocation() else {return}
                    
                    guard CityController.shared.verifyLocationFor(city: city) else {
                        presentSimpleAlert(viewController: self, title: "Sorry!", message: "Every Teen Seen is a group that is growing rapidly, but we are not yet in your area! Be sure to check back regularly!")
                        return
                    }
                    
                    // Update locaiotn in CoreData
                    UserLocationController.shared.update(location: location, lat: location.latitude,
                                                         long: location.longitude, zip: zip, cityName: city.city)
                    
                    presentLogoutAndSignUpPage(viewController: self)
                })
            }
        }
    }
    
    private func informTheUserAboutLocation() {
        self.hideActivityIndicator()
        
        let alert = UIAlertController(title: "Location Services", message: "You have denied access to let ETS use your location while being used. Enter your zipcode in manually or go to settings!", preferredStyle: .alert)
        
        let settingsAlert = UIAlertAction(title: "Go to settings", style: .default) { (_) in
            // Naviate them to settings
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        
        let enterManualAlert = UIAlertAction(title: "Enter Manually", style: .cancel) { (_) in
            self.locationIsDenied = true
        }
        
        alert.addAction(enterManualAlert)
        alert.addAction(settingsAlert)
        
        self.present(alert, animated: true, completion: nil)
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
            
            let userLocation = UserLocation(latitude: lat, longitude: long, zip: zip, cityName: "")
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
}
