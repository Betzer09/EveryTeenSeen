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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("We have permission to use the user's location")
            locationManager.requestLocation()
            
            // If we have permission to have the location save it
            self.fetchTheUsersLocation(completion: { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                UserLocationController.shared.createLocationWith(lat: location.latitude , long: location.longitude, zip: zip)
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location: \(location)")
        }
        
        // Write a function to grab and update the user's location
        self.fetchTheUsersLocation { (location) in
            guard let location = location, let zip = location.zipcode else {return}
            
            UserLocationController.shared.update(lat: location.latitude, long: location.longitude, zip: zip)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Error with location Manager: \(error.localizedDescription)")
    }
    
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
    
}









