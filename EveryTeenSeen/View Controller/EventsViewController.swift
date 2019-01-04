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
    var clearFilterButtonPressed = false
    var eventsSearchedByDistance: [Event] = [] {
        didSet {
            if eventsSearchedByDistance.count == 0 && clearFilterButtonPressed == true {
                presentSimpleAlert(viewController: self, title: "No Events", message: "Unfortunately, there are no scheduled events in this area at this time. You can try increasing your distance in your profile.")
                noEventsNearybyView.isHidden = false
            } else {
                noEventsNearybyView.isHidden = true
            }
        }
    }
    private let refreshControl = UIRefreshControl()
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        self.checkIfWeNeedToRemoveUserFromAdminRights()
        DispatchQueue.main.async {
            self.locationManager.requestLocation()
            self.eventsTableView.reloadData()
        }
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
    @IBAction func viewProfileButtonPressed(_ sender: Any) {
        presentUserProfile(viewController: self)
    }
    
    @IBAction func searchEventByDistanceButtonPressed(_ sender: Any) {
        self.clearFilterButtonPressed = false
        EventController.shared.fetchAllEvents()
        self.searchEventByDistanceGroupView.isHidden = true
        guard let locationThatUserPicked = placemark else {NSLog("We don't have a location from the user!")
            presentSimpleAlert(viewController: self, title: "You need to pick a city!", message: "")
            return
        }
        guard let events = EventController.shared.events else {return}
        var filteredEvents: [Event] = []
        for event in events {
            let distance = findTheDistanceBetweenTwoPoints(firstLat: locationThatUserPicked.coordinate.latitude, firstLong: locationThatUserPicked.coordinate.longitude, secondLat: event.lat, secondLong:  event.long)
        
            if Int(userPickedDistanceSlider.value) <= Int(distance)   {
                filteredEvents.append(event)
            }
        }
        
        self.eventsSearchedByDistance = filteredEvents
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
    }
    
    @IBAction func clearFilterButtonPressed(_ sender: Any) {
        self.clearFilterButtonPressed = true
        self.eventsSearchedByDistance.removeAll()
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
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
        locationSearchBar.placeholder = "Search For City"
        
        eventsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshEvents), for: .valueChanged)
        refreshControl.tintColor = UIColor.myPurple
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching New Events...")
    }
    
    
    private func setUpNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: EventController.eventWasUpdatedNotifcation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfilePicture), name: UserController.shared.profilePictureWasUpdated, object: nil)
    }
    
    private func setTableViewHeight() {
        self.eventsTableView.estimatedRowHeight = self.view.bounds.height * 0.7
        self.eventsTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func loadAllEvents(completion: @escaping (_ success: Bool) -> Void = {_ in}) {
        EventController.shared.fetchAllEvents { (success,events) in
            guard success else {return}

            DispatchQueue.main.async {
                self.eventsTableView.reloadData()
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                completion(true)
            }
            self.checkIfThereAreEventsInRange(events: events)
        }
    }
    
    // MARK: - Functions
    
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
    
    private func checkIfThereAreEventsInRange(events: [Event]) {
        /// Check to see if there are any events before the table view is prepared
        if EventController.shared.filterEventsBy(distance: Int(UserController.shared.loadUserProfile()?.eventDistance ?? 50), events: events).isEmpty {
            
            self.noEventsNearybyView.isHidden = false
        } else {
            self.noEventsNearybyView.isHidden = true
        }
    }
    
    // MARK: - Objective-C Functions
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
        if eventsSearchedByDistance.isEmpty {
            self.checkIfThereAreEventsInRange(events: EventController.shared.events ?? [])
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
            
            guard let unfilteredEvents = EventController.shared.events else {return UITableViewCell()}
            let distance = UserController.shared.loadUserProfile()?.eventDistance ?? 50
            var events: [Event] = []
            
            if eventsSearchedByDistance.count == 0 {
                events = EventController.shared.filterEventsBy(distance: Int(distance) , events: unfilteredEvents)
            } else {
                events = self.eventsSearchedByDistance
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
            guard let unfilteredEvents = EventController.shared.events else {return 0}
            let distance = UserController.shared.loadUserProfile()?.eventDistance ?? 50
            var events: [Event] = []
            
            if eventsSearchedByDistance.count == 0 {
                events = EventController.shared.filterEventsBy(distance: Int(distance) , events: unfilteredEvents)
                
            } else {
                events = self.eventsSearchedByDistance
            }
            
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
        
        var events: [Event] = []
        guard let unfilteredEvents = EventController.shared.events else {return}
        
        if eventsSearchedByDistance.count == 0 {
            events = EventController.shared.filterEventsBy(distance: Int(UserController.shared.loadUserProfile()?.eventDistance ?? 50) , events: unfilteredEvents)
            
        } else {
            events = self.eventsSearchedByDistance
        }
        
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
