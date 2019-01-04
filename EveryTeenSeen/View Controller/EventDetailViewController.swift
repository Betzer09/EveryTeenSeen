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
    @IBOutlet weak var deleteEventButton: UIButton!
    @IBOutlet weak var editEventButton: UIButton!
    
    // Weekday Outlets
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventLocationNameLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var donateButton: UIButton!
    
    // Bottom half outlets
    @IBOutlet weak var attendEventButton: UIButton!
    
    // Profile Picture Outlets
    @IBOutlet weak var profilePictureGroupStackView: UIStackView!
    @IBOutlet weak var loadingProfilePictureView: UIView!
    @IBOutlet weak var loadingProfilePicturesAnimatorView: UIActivityIndicatorView!
    @IBOutlet weak var attendingCountLabel: UILabel!
    @IBOutlet weak var loadingEventsLabel: UILabel!
    
    
    // MARK: - Properties
    var event: Event?
    
    // This is used to store the email being passes
    var emailToPassToAboutUserVC: String?
    
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserProfileVC" {
            guard let destination = segue.destination as? AboutUserViewController, let email = emailToPassToAboutUserVC else {return}
            destination.email = email
        }
        
        if segue.identifier == "updateEventVC" {
            guard let destination = segue.destination as? CreateEventViewController, let event = event else {return}
            destination.event = event
        }
    }
    
    // MARK: - Actions
    
    @IBAction func donateButtonPressed(_ sender: Any) {
        openDonationPage(vc: self)
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
                guard let count = updatedEvent?.attending?.count else {return}
                DispatchQueue.main.async {
                    self.attendingCountLabel.text = "Attending: \(count)"
                }
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
                guard let count = updatedEvent?.attending?.count else {return}
                DispatchQueue.main.async {
                    self.attendingCountLabel.text = "Attending: \(count)"
                }
                event.attending = updatedEvent?.attending
                self.setAttendingButtonAsGrey()
            })
        }
    }
    
    @IBAction func deleteEventButtonPressed(_ sender: Any) {
        guard let event = event else {return}
        confirmationAlert(viewController: self, title: "Are you sure you want to delete \"\(event.title)\"?", message: "This action can't be reversed!", confirmButtonTitle: "Delete Event", cancelButtonTitle: "Cancel") { (done) in
            guard done else {return}
            EventController.shared.deleteEventFromFireBase(event: event) { (done) in
                if done {
                    presentSimpleAlert(viewController: self, title: "Success!",
                                       message: "\"\(event.title)\" has been deleted succesfully!", completion: { (done) in
                        guard done else {return}
                        EventController.shared.fetchAllEvents()
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    presentSimpleAlert(viewController: self, title: "Oops!", message: "There was a problem deleting this event!", completion: {(done ) in
                        guard done else {return}
                        EventController.shared.fetchAllEvents()
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
    
    
    @IBAction func presentUserProfileButtonPressed(_ sender: UIButton) {
        guard let email = sender.titleLabel?.text else {return}
        self.emailToPassToAboutUserVC = email
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toUserProfileVC", sender: nil)
        }
    }
    
    
    // MARK: - Functions
    private func setUpView() {
        
        guard let event = event,
            let attendings = event.attending,
            let imageData = event.photo?.imageData,
            let user = UserController.shared.loadUserProfile(),
            let userEmail = user.email,
            let usertype = user.usertype else {return}
        
        eventNameLabel.text = event.title
        eventImageView.image = UIImage(data: imageData)
        
        eventAddressLabel.text = event.address
        eventSummary.text = event.eventInfo
        eventTimeLabel.text = event.eventTime
        attendEventButton.layer.cornerRadius = 15
        deleteEventButton.layer.cornerRadius = 15
        editEventButton.layer.cornerRadius = 15
        donateButton.layer.cornerRadius = 15
        
        attendingCountLabel.text = "Attending: \(attendings.count)"
        
        if attendings.contains(userEmail) {
            attendEventButton.setTitle("Unattend event", for: .normal)
            attendEventButton.backgroundColor = UIColor.lightGray
        }
        
        if usertype == UserType.leadCause.rawValue {
            self.deleteEventButton.isHidden = false
            self.editEventButton.isHidden = false
        }
        
        self.setUpCalanderLabels()
        self.setUpLocationLabels()
        self.setUpProfilePictureForAttending()
    }
    
    /// Configures all of the attending buttons
    private func setUpProfilePictureForAttending() {
        guard let user = UserController.shared.loadUserProfile(), let usertype = user.usertype, let event = event else {return}
        
        EventController.shared.fetchAllProfilePicturesFor(event: event) { (photos) in
            guard let photos = photos else {
                self.loadingProfilePicturesAnimatorView.stopAnimating()
                return
            }
            
            let buttons = getAllButtons(view: self.profilePictureGroupStackView)
            
            for button in buttons {
                // Congirue the buttons
                button.setTitle("", for: .normal)
                button.isUserInteractionEnabled = false
            }
            
            if photos.count >= 1 {
                for i in 0...photos.count - 1 {
                    let photo = photos[i]
                    guard let photoImage = UIImage(data: photo.imageData) else {return}
                    let resizedImage = resizeImage(image: photoImage, targetSize: CGSize(width: 50, height: 50))
                    
                    DispatchQueue.main.async {
                        buttons[i].imageView?.contentMode = .scaleAspectFit
                        buttons[i].setImage(resizedImage, for: .normal)
                        buttons[i].setTitle(photo.photoPath, for: .normal)
                        buttons[i].setTitleColor(.clear, for: .normal)
                    }
                    if usertype == UserType.leadCause.rawValue {
                        buttons[i].isUserInteractionEnabled = true
                    } else {
                        buttons[i].isUserInteractionEnabled = false
                    }
                }
                self.loadingProfilePictureView.isHidden = true
                self.loadingProfilePicturesAnimatorView.stopAnimating()
            } else {
                self.loadingEventsLabel.text = "Be the first to Join!"
                self.loadingProfilePicturesAnimatorView.stopAnimating()
            }
            
        }
    }
    
    func setUpNotificaitonObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfilePicture), name: UserController.shared.profilePictureWasUpdated, object: nil)
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
            self.eventMeetUpDateLabel.text = formatStringDateForEventTimeAsString(string: string) + "\n" + eventTime
            
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
    @objc func reloadProfilePicture() {
        NSLog("Profile picture has been updated")
        
        guard let unwrappedImage = UserController.shared.profilePicture.circleMasked else {return}
        let profileImage = resizeImage(image: unwrappedImage , targetSize: CGSize(width: 40.0, height: 40.0))
        let profileButton: UIButton = UIButton(type: .custom)
        let profilePicutre = resizeImage(image: profileImage, targetSize: CGSize(width: 40.0, height: 40.0))
        profileButton.setImage(profilePicutre, for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        }
    }
}

// MARK: - Set Up Navigation
extension EventDetailViewController {
    
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let backButton: UIButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.titleView = happyImage
    }
    
    // MARK: - Objective-C Functions
    @objc func backButtonPressed() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
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
