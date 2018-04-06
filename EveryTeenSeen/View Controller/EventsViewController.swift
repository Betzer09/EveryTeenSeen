//
//  EventsTableViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import MapKit

class EventsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        locationManager.requestLocation()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNotificationObservers()
        self.configureNavigationBar()
        self.loadAllEvents { (success) in
            guard success else {return}
            self.checkIfUserHasAccount()
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindToEventsVC(segue: UIStoryboardSegue){}

    // MARK: - Set Up View
    private func setUpView() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    
    private func setUpNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: EventController.eventWasUpdatedNotifcation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfilePicture), name: UserController.shared.profilePictureWasUpdated, object: nil)
    }
    
    private func setTableViewHeight() {
        self.tableView.estimatedRowHeight = self.view.bounds.height * 0.7
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func loadAllEvents(completion: @escaping (_ success: Bool) -> Void = {_ in}) {
        EventController.shared.fetchAllEvents { (success) in
            guard success else {return}
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                completion(true)
            }
        }
    }
    
    // MARK: - Functions
    private func checkIfUserHasAccount() {
        guard UserController.shared.loadUserProfile() == nil else {return}
        presentLoginAlert(viewController: self)
    }
    
    // MARK: - Objective-C Functions
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func reloadProfilePicture() {
        NSLog("Profile picture has been updated")
        
        guard let unwrappedImage = UserController.shared.profilePicture.circleMasked else {return}
        let profileImage = resizeImage(image: unwrappedImage, targetSize: CGSize(width: 40.0, height: 40.0))
        let profileButton: UIButton = UIButton(type: .custom)
        let profilePicutre = resizeImage(image: profileImage, targetSize: CGSize(width: 40.0, height: 40.0))
        profileButton.setImage(profilePicutre, for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        }
    }
}

// MARK: - Table View Delegate
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
        
        guard let events = EventController.shared.events else {return UITableViewCell()}
        cell.event = events[indexPath.row]
        
        cell.layer.cornerRadius = 15
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.shared.events?.count ?? 0
    }
    
    // MARK: - Table View Fnctions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height * 0.62
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let _ = UserController.shared.loadUserProfile() else {
            presentLoginAlert(viewController: self)
            return
        }
        
        if segue.identifier == "toEventDetailVC" {
            guard let destination = segue.destination as? EventDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow,
                let event = EventController.shared.events?[indexPath.row]
                else {print(segue.destination);return}
            destination.event = event
        }
        
    }

}

// MARK: - Navigation Bar
extension EventsViewController {
    
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        let profilePicture = UserController.shared.profilePicture
        var smallAvatar = #imageLiteral(resourceName: "smallAvatar")
        if profilePicture != #imageLiteral(resourceName: "smallAvatar") {
            if let profilePic = profilePicture.circleMasked {
                smallAvatar = resizeImage(image: profilePic, targetSize: CGSize(width: 40, height: 40))
            }
        }
        let profileImage = smallAvatar

        profileButton.setImage(profileImage, for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = resizeImage(image: #imageLiteral(resourceName: "HappyLogo"), targetSize: CGSize(width: 40.0, height: 40.0))
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        self.navigationItem.titleView = happyImage
    }
    
    // MARK: - Objective-C Functions
    @objc func configureLocation() {
        presentSimpleAlert(viewController: self, title: "Coming Soon!", message: "This feature has not yet been configured yet!")
    }
    
    @objc func segueToProfileView() {
        guard UserController.shared.loadUserProfile() != nil else {
            presentLoginAlert(viewController: self)
            return
        }
        presentUserProfile(viewController: self)
    }
}

// MARK: - User Location Updater
extension EventsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first {
            
            // Checks if the location should be updated
            guard findTheDistanceWith(lat: location.coordinate.latitude , long: location.coordinate.longitude) == true else {
                print("Location does not need updated")
                manager.stopUpdatingLocation()
                return
            }
            
            // Write a function to grab and update the user's location
            self.fetchTheUsersLocation { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                
                CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                    UserLocationController.shared.createLocationWith(lat: location.latitude, long: location.longitude, zip: zip, cityName: city.cityName, state: city.state)
                })
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
            
            guard let placemark = placemarks?.first, let zip = placemark.postalCode else {
                    completion(nil)
                    NSLog("Error updating user locaiton in function: \(#function)")
                    return
            }
            
            let lat = userLocation.coordinate.latitude
            let long = userLocation.coordinate.longitude
            
            let userLocation = UserLocation(latitude: lat, longitude: long, zip: zip, cityName: "", state: "")
            completion(userLocation)
            self.locationManager.stopUpdatingLocation()
        })
    }
}



