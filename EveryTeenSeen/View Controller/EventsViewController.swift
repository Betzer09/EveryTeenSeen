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
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Search City View
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var searchEventByDistanceGroupView: UIView!
    @IBOutlet weak var searchEventsByDistanceButton: UIButton!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var userPickedDistanceSlider: UISlider!
    @IBOutlet weak var clearFilterButton: UIButton!
    
    // No Events View
    @IBOutlet weak var noEventsNearybyView: UIView!
    @IBOutlet weak var viewProfileButton: UIButton!
    
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = []
    var placemark: MKPlacemark?
    
    private let refreshControl = UIRefreshControl()
    private var searchButtonPressed = false
    /// These events should be used by the table view
    private var events: [Event]? {
        didSet{
            self.reloadTableView()
            if events?.count == 0 {
                self.noEventsNearybyView.isHidden = false
            } else {
                self.noEventsNearybyView.isHidden = true
            }
            
            if searchButtonPressed && events?.count == 0 {
                guard let placemark = placemark else {return}
                presentSimpleAlert(viewController: self, title: "No Events Found", message: "Unfortunately, there are no events near \(placemark.name ?? ""). You can try increasing the distance from the city you picked and try againf.")
            }
        }
    }
    
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        self.checkIfWeNeedToRemoveUserFromAdminRights()
        EventController.shared.fetchAllEvents { (success, fetchedEvents) in
            guard success else {return}
            
            self.configurePropertiesForTableView()
            
        }
        DispatchQueue.main.async {
            self.locationManager.requestLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNotificationObservers()
        self.configureNavigationBar()
        self.loadAllEvents { (success) in
            guard success else {return}
            self.configurePropertiesForTableView()
            self.checkIfUserHasAccount()
            self.viewProfileButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    @IBAction func viewProfileButtonPressed(_ sender: Any) {
        presentUserProfile(viewController: self)
    }
    
    @IBAction func searchEventByDistanceButtonPressed(_ sender: Any) {
        self.searchButtonPressed = true
        EventController.shared.fetchAllEvents { (success, _) in
            guard success else {return}
            self.configurePropertiesForTableView()
        }
        self.searchEventByDistanceGroupView.isHidden = true
    }
    
    @IBAction func clearFilterButtonPressed(_ sender: Any) {
        self.searchButtonPressed = false
        EventController.shared.fetchAllEvents { (success, _) in
            guard success else {return}
            self.configurePropertiesForTableView()
        }
        DispatchQueue.main.async {
            self.searchEventByDistanceGroupView.isHidden = true
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        distanceLabel.text = "\(Int(sender.value)) mile radius from the city you search."
    }
    
    @IBAction func unwindToEventsVC(segue: UIStoryboardSegue){}
    
    // MARK: - Set Up View
    private func setUpView() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        searchEventsByDistanceButton.layer.cornerRadius = 10
        clearFilterButton.layer.cornerRadius = 10
        viewProfileButton.layer.cornerRadius = 15
        locationSearchBar.sizeToFit()
        locationSearchBar.placeholder = "Search For A City"
        
        eventsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshEvents), for: .valueChanged)
        refreshControl.tintColor = UIColor.myPurple
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching New Events...")
        
        guard UserController.shared.loadUserProfile() != nil else {
            self.viewProfileButton.isHidden = true
            return
        }
    }
    
    
    private func setUpNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: EventController.eventWasUpdatedNotifcation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfilePicture), name: UserController.shared.profilePictureWasUpdated, object: nil)
    }
    
    private func setTableViewHeight() {
        self.eventsTableView.estimatedRowHeight = self.view.bounds.height * 0.7
        self.eventsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func loadAllEvents(completion: @escaping (_ success: Bool) -> Void = {_ in}) {
        EventController.shared.fetchAllEvents { (success,events) in
            guard success else {return}
            
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                completion(true)
            }
        }
    }
    
    // MARK: - Functions
    
    /// Sets the events property
    func configurePropertiesForTableView() {
        // We need to know if there is a user
        // We need to know if the search button has been pressed
        let allEvents = EventController.shared.allEvents ?? []
        if let _ = UserController.shared.loadUserProfile() {
            if searchButtonPressed {
                // return events near city
                returnEventsNearCityWith(allEvents: allEvents)
            } else {
                // return events near user
                self.events = EventController.shared.eventsNearUserLocation
            }
        } else {
            // There is not a user return all events within a 50 mile radius
            if searchButtonPressed {
                // Returns events near city
                returnEventsNearCityWith(allEvents: allEvents)
            } else {
                // Returns within a 50 mile radius
                guard let location = UserLocationController.shared.fetchUserLocation() else {return}
                self.events = allEvents.filter({ findTheDistanceBetweenTwoPoints(firstLat: location.latitude, firstLong: location.longitude, secondLat: $0.lat, secondLong: $0.long) <= Double(50)})
            }
        }
    }
    
    /// Returns all the events near a city
    private func returnEventsNearCityWith(allEvents: [Event]) {
        guard let placemark = placemark else {
            presentSimpleAlert(viewController: self, title: "Try picking another City", message: "")
            return
        }
        self.events = allEvents.filter({ findTheDistanceBetweenTwoPoints(firstLat: placemark.coordinate.latitude, firstLong: placemark.coordinate.longitude, secondLat: $0.lat, secondLong: $0.long) <= Double(userPickedDistanceSlider.value)})
    }
    
    func checkIfWeNeedToRemoveUserFromAdminRights() {
        AdminPasswordController.shared.fetchAdminPasswordFromFirebase { (needToSignUserOut) in
            guard needToSignUserOut else {return}
            
            let alert = UIAlertController(title: "Admin password has changed!", message: "Contact ETS for the new password until then you will not be able to create new events!", preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                presentLogoutAndSignUpPage(viewController: self)
            })
            
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func checkIfUserHasAccount() {
        guard UserController.shared.loadUserProfile() == nil else {return}
        presentLoginAlert(viewController: self)
    }
    
    @objc func refreshEvents() {
        EventController.shared.fetchAllEvents { (success, _) in
            guard success else {return}
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Objective-C Functions
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
    }
    
    @objc func hideLocationView() {
        self.view.endEditing(true)
        searchEventByDistanceGroupView.isHidden = true
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == eventsTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
            
            guard let events = events else {return UITableViewCell()}
            if events.count == 0 {
                return UITableViewCell()
            }
            cell.event = events[indexPath.row]
            
            cell.layer.cornerRadius = 15
            cell.selectionStyle = .none
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            
            let location = matchingItems[indexPath.row].placemark
            cell.textLabel?.text = location.name
            cell.detailTextLabel?.text = parseAddress(selectedItem: location)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == eventsTableView {
            guard let events = events else {return 0}
            return events.count
        } else {
            return matchingItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == eventsTableView {
            if self.view.bounds.height <= 800 {
                return self.view.bounds.height * 0.65
            } else {
                return self.view.bounds.height * 0.53
            }
        } else {
            return self.searchEventByDistanceGroupView.bounds.height * 0.2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == locationTableView {
            self.locationTableView.isHidden = true
            let location = matchingItems[indexPath.row].placemark
            locationSearchBar.text = location.name
            self.view.endEditing(true)
            self.placemark = location
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let events = events else {return}
        
        guard let _ = UserController.shared.loadUserProfile() else {
            presentLoginAlert(viewController: self)
            return
        }
        
        if segue.identifier == "toEventDetailVC" {
            guard let destination = segue.destination as? EventDetailViewController,
                let indexPath = eventsTableView.indexPathForSelectedRow else {print(segue.destination); return}
            destination.event = events[indexPath.row]
        }
    }
}
// MARK: - Search Bar Functions
extension EventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.locationTableView.isHidden = false
        updateSearchResults(for: searchBar) { (results) in
            self.matchingItems = results
            self.locationTableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.locationTableView.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchEventByDistanceGroupView.isHidden = true
        self.locationTableView.isHidden = true
        self.view.endEditing(true)
    }
}

// MARK: - Navigation Bar
extension EventsViewController {
    
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(hamburgerButtonPressed), for: .touchUpInside)
        
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
    @objc func hamburgerButtonPressed() {
        if self.searchEventByDistanceGroupView.isHidden == false {
            self.searchEventByDistanceGroupView.isHidden = true
        } else {
            self.searchEventByDistanceGroupView.isHidden = false
        }
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
        if let location = locations.first {
            
            // Checks if the location should be updated
            guard findTheDistanceWith(lat: location.coordinate.latitude , long: location.coordinate.longitude) == true else {
                print("Location does not need updated")
                DispatchQueue.main.async {
                    manager.stopUpdatingLocation()
                }
                return
            }
            
            // Write a function to grab and update the user's location
            self.fetchTheUsersLocation { (location) in
                guard let location = location, let zip = location.zipcode else {return}
                
                CityController.shared.fetchCityWith(zipcode: zip, completion: { (city) in
                    UserLocationController.shared.createLocationWith(lat: location.latitude, long: location.longitude, zip: zip, cityName: city.cityName, state: city.state)
                    
                    DispatchQueue.main.async {
                        manager.stopUpdatingLocation()
                    }
                    
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
