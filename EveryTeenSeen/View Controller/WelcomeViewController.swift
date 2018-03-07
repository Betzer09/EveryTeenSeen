//
//  WelcomeViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/1/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import MapKit

class WelcomeViewController: UIViewController {
    // MARK: - Properties
    let locationManager = CLLocationManager()
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    
    // MARK: - Actions
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        
        var zipcodeTextField: UITextField!
        
        guard let zipcode = UserLocationController.shared.fetchUserLocation()?.zipcode else {print("Error: we do not have permission to access thier location"); return}
        
        let alert = UIAlertController(title: "Enter Your Zipcode", message: "Every Teen Seen is a group that is growing rapidly, but we are only in a few locations.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "83274"
            textField.keyboardType = .decimalPad
            textField.text = zipcode
            zipcodeTextField = textField
        }
        
        let verifyAction = UIAlertAction(title: "Verify", style: .default) { (_) in
            guard let zipcodeString = zipcodeTextField.text, let zipcode = Int(zipcodeString) else {return}
            CityController.shared.fetchCityWith(zipcode: "\(zipcode)", completion: { (City) in
                // Check to see if the state is correct
                guard CityController.shared.verifyLocationFor(city: City) else {
                    
                    // If the state isn't in utah alert the user
                    presentSimpleAlert(viewController: self, title: "Error", message: "You're location is not supported yet!")
                    return
                }
                
                // show joinViewController
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "joinVC") as? JoinViewController else {return}
                vc.zipcode = zipcodeString
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        alert.addAction(verifyAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UI Functions
    private func setUpView() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension WelcomeViewController: CLLocationManagerDelegate {
   
    // Saves the location when permission is granted
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("We have permission to use the user's location")
            locationManager.requestLocation()
            
            // Check to see if we already have a location
            guard UserLocationController.shared.fetchUserLocation() == nil else {return}
            
            // If there isn't a location create and save it
            self.fetchTheUsersLocation(completion: { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                UserLocationController.shared.createLocationWith(lat: location.latitude , long: location.longitude, zip: zip)
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
