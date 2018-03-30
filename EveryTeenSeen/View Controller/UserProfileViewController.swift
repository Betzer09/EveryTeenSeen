//
//  UserProfileViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/17/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import CoreData

class UserProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usertypeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var tableviewHeaderLabel: UILabel!
    
    // Table View Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Interest View outlets
    @IBOutlet weak var interestsGroupView: UIView!
    @IBOutlet weak var firstRowInterestStackView: UIStackView!
    @IBOutlet weak var secondRowInterestStackView: UIStackView!
    @IBOutlet weak var thirdRowInterestStackView: UIStackView!
    
    //Buttons
    @IBOutlet weak var firstInterest: UIButton!
    @IBOutlet weak var secondInterest: UIButton!
    @IBOutlet weak var thirdInterest: UIButton!
    @IBOutlet weak var fourthInterest: UIButton!
    @IBOutlet weak var fifthInterest: UIButton!
    @IBOutlet weak var sixthInterest: UIButton!
    @IBOutlet weak var seventhInterest: UIButton!
    @IBOutlet weak var eigthInterest: UIButton!
    @IBOutlet weak var ninthInterest: UIButton!
    
    
    // MARK: - View Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        self.configureAllButtons()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - Actions
    @IBAction func createEventButtonPressed(_ sender: Any) {
        presentCreateEventVC(viewController: self)
    }
    
    @IBAction func addInterestButtonPressed(_ sender: Any) {
        
        guard let interests = UserController.shared.loadUserProfile()?.interests?.array as? [Interest] else {return}
        
        if interests.count >= 9 {
            presentSimpleAlert(viewController: self, title: "You're amazing!", message: "You can only have nine interests though!")
            return
        }
    
        var interestTextField: UITextField!
        
        let alert = UIAlertController(title: "Create an Interest!", message: "These will be public to Admin users in your area to help plan future events.", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Snowboarding"
            textfield.autocapitalizationType = .words
            interestTextField = textfield
        }
        
        let okActions = UIAlertAction(title: "Create Interest", style: .default) { (_) in
            guard let name = interestTextField.text, let user = UserController.shared.loadUserProfile() else {return}
            let interestsNames = interests.flatMap({ $0.name })
            
            if interestsNames.contains(name) {
                presentSimpleAlert(viewController: self, title: "Oops", message: "You already have that interest!")
                return
            }
            InterestController.shared.createInterestWith(user: user, and: name, completion: { (done) in
                guard done else {return}
                self.configureAllButtons()
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okActions)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logUserOutButtonPressed(_ sender: Any) {
        
        presentLogoutAlert { (success) in
            guard success else {return}
            UserController.shared.signUserOut { (successfullySignedUserOut, error) in
                if let error = error {
                    NSLog("Error signing user out! : \(error.localizedDescription)")
                    presentSimpleAlert(viewController: self, title: "Problem Logging out!", message: error.localizedDescription)
                }
                guard successfullySignedUserOut else {return}
                presentLogoutAndSignUpPage(viewController: self)
            }
        }
    }
    
    // MARK: - Functions 
    private func setUpView() {
        
        EventController.shared.fetchAllEvents { (doneFetching) in
            guard doneFetching else {return}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        createEventButton.layer.cornerRadius = createEventButton.bounds.height / 2
        
        guard let user = UserController.shared.loadUserProfile(), let userLocation = user.location else {return}
        
        if user.usertype == UserType.leadCause.rawValue {
            usertypeLabel.text = "Admin"
            createEventButton.isHidden = false
        }
        
        addressLabel.text = "\(userLocation.cityName ?? ""), \(userLocation.state ?? ""), \(userLocation.zipcode ?? "")"
        fullnameLabel.text = user.fullname
        distanceLabel.text = "\(user.eventDistance) mile radius"
        

    }
    
    private func presentLogoutAlert(completion: @escaping(_ success: Bool) -> Void) {
        let alert = UIAlertController(title: "Do you want to logout?", message: "", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Logout", style: .default) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            completion(false)
        }
        
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// This sets up the user's tableview depending on their usertype
    private func setUpTableViewWith(events: [Event]) -> [Event] {
        guard let user = UserController.shared.loadUserProfile(), let email = user.email else {return []}
        
        var eventsToReturn: [Event] = []
        
        if user.usertype == UserType.leadCause.rawValue {
            // Show the user the events that they have created
            
            for event in events {
                if event.userWhoPosted == user.fullname {
                    eventsToReturn.append(event)
                }
            }
        } else {
            // Show the user to events they are attending
            
            for event in events {
                guard let attending = event.attending else {return []}
                if attending.contains(email) {
                    eventsToReturn.append(event)
                }
            }
            
            tableviewHeaderLabel.text = "Events I'm Attending"
        }
        return eventsToReturn
    }
}


// MARK: - Table View Data Source
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
        
        cell.layer.cornerRadius = 15
        cell.selectionStyle = .none
        
        
        guard let allEvents = EventController.shared.events else {return UITableViewCell()}
        let events = setUpTableViewWith(events: allEvents)
        cell.event = events[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let allEvents = EventController.shared.events else {return 0}
        let events = setUpTableViewWith(events: allEvents)
        return events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height * 0.62
    }
}

// MARK: - Set Up Interest Buttons
extension UserProfileViewController {
    /// Gets all buttons in a view
    private func getAllButtons(view: UIView) -> [UIButton] {
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
    
    private func configureAllButtons() {
        let buttons = getAllButtons(view: interestsGroupView)
        guard let interests = UserController.shared.loadUserProfile()?.interests?.array as? [Interest] else {return}
        
        
        // Make all buttons have no title
        for i in 0...buttons.count - 1 {
            DispatchQueue.main.async {
                buttons[i].setTitle("", for: .normal)
            }
        }
        
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












