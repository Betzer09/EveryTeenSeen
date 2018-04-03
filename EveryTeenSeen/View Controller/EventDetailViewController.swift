//
//  EventDetailViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/26/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventMeetUpDateLabel: UILabel!
    @IBOutlet weak var eventContentView: UIView!
    @IBOutlet weak var eventSummary: UITextView!

    
    
    // Weekday Outlets
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventLocationNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    
    // Bottom half outlets
    @IBOutlet weak var attendEventButton: UIButton!
    
    
    // MARK: - Properties
    var event: Event?

    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNotificaitonObservers()
        self.configureNavigationBar()
    }
    
    
    @IBAction func attendEventButtonPressed(_ sender: Any) {
        guard let event = event, let user = UserController.shared.loadUserProfile() else {
                NSLog("Error attending event!")
                return
        }
        
        if attendEventButton.titleLabel?.text == "Unattend event" {
            // They are attending event and want to mark as unattending
            EventController.shared.isPlanningOnAttending(event: event, user: user , isGoing: false, completion: { (errorString) in
                guard let errorString = errorString else {return}
                NSLog("Error with user unattending event! :\(errorString)")
                presentSimpleAlert(viewController: self, title: "Problem Unattending event!", message: errorString)
            }, completionHandler: { (updatedEvent) in
                // TODO: - Update the attending label
                event.attending = updatedEvent?.attending
                self.setAttendingButtonToYellow()
            })
        } else {
            // They aren't attending and want to
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: true, completion: { (errorString) in
                guard let errorString = errorString else {return}
                NSLog("Error with user attending event! :\(errorString)")
                presentSimpleAlert(viewController: self, title: "Problem Attending event!", message: errorString)
            }, completionHandler: { (updatedEvent) in
                // TODO: - Update the attending label
                event.attending = updatedEvent?.attending
                self.setAttendingButtonAsGrey()
            })
        }
    }
    
    // MARK: - Functions
    private func setUpView() {
        
        guard let event = event, let attendings = event.attending, let imageData = event.photo?.imageData, let userEmail = UserController.shared.loadUserProfile()?.email else {return}
        
        eventNameLabel.text = event.title
        eventImageView.image = UIImage(data: imageData)
        
        eventAddressLabel.text = event.address
        eventSummary.text = event.eventInfo
        eventTimeLabel.text = event.eventTime
        attendEventButton.layer.cornerRadius = 15
        
        if attendings.contains(userEmail) {
            attendEventButton.setTitle("Unattend event", for: .normal)
            attendEventButton.backgroundColor = UIColor.lightGray
        }
        
        self.setUpCalanderLabels()
        self.setUpLocationLabels()
    }
    
    func setUpNotificaitonObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNavBar), name: UserController.shared.profilePictureWasUpdated, object: nil)
    }
    
    /// This should be set when they are going to the event
    func setAttendingButtonToYellow() {
        DispatchQueue.main.async {
            self.attendEventButton.backgroundColor = UIColor(red: divideNumberForColorWith(number: 255), green: divideNumberForColorWith(number: 194), blue: 0, alpha: 1)
            self.attendEventButton.setTitle("Attend event", for: .normal)
        }
        
    }
    
    /// This should be set when they are not going to the event
    func setAttendingButtonAsGrey() {
        DispatchQueue.main.async {
            self.attendEventButton.backgroundColor = UIColor.lightGray
            self.attendEventButton.setTitle("Unattend event", for: .normal)
        }
    }
    
    func setUpCalanderLabels() {
        guard let string = event?.dateHeld, let eventTime = event?.eventTime else {return}
        
        parseStringByCommasForDateAndLocation(string: string) { (weekday, finalDate) in
            self.weekdayLabel.text = weekday
            self.eventDateLabel.text = String(finalDate.dropFirst())
            self.eventMeetUpDateLabel.text = String(finalDate.dropFirst()) + "\n" + eventTime
            
        }
    }
    
    
    func setUpLocationLabels() {
        guard let address = event?.address else {return}

        parseStringByCommasForDateAndLocation(string: address) { (locationTitle, stringPhrase) in
            self.eventLocationNameLabel.text = locationTitle
            self.eventLocationLabel.text = String(stringPhrase.dropFirst())
        }
    }
    
    // MARK: - Objective - C Functions
    @objc func reloadNavBar() {
        DispatchQueue.main.async {
            self.configureNavigationBar()
        }
    }
}

// MARK: - Set Up Navigation
extension EventDetailViewController {
    
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let backButton: UIButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        guard let unwrappedImage = UserController.shared.profilePicture?.circleMasked else {return}
        let profileImage = resizeImage(image: unwrappedImage , targetSize: CGSize(width: 40.0, height: 40.0))
        profileButton.setImage(profileImage, for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = resizeImage(image: #imageLiteral(resourceName: "HappyLogo"), targetSize: CGSize(width: 40.0, height: 40.0))
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.titleView = happyImage
    }
    
    // MARK: - Objective-C Functions
    @objc func configureLocation() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func segueToProfileView() {
        guard UserController.shared.loadUserProfile() != nil else {
            presentLoginAlert(viewController: self)
            return
        }
        presentUserProfile(viewController: self)
    }
}
