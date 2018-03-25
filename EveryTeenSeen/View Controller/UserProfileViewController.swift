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
    
    // Table View Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func createEventButtonPressed(_ sender: Any) {
        presentCreateEventVC(viewController: self)
    }
    
    @IBAction func addInterestButtonPressed(_ sender: Any) {
    
        var interestTextField: UITextField!
        
        let alert = UIAlertController(title: "Create an Interest!", message: "These will be public to Admin users in your area to help plan future events.", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            textfield.placeholder = "Snowboarding"
            textfield.autocapitalizationType = .words
            interestTextField = textfield
        }
        
        let okActions = UIAlertAction(title: "Create Interest", style: .default) { (_) in
            guard let text = interestTextField.text else {return}
            
            InterestController.shared.createInterest(name: text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okActions)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Functions 
    private func setUpView() {
        createEventButton.layer.cornerRadius = createEventButton.bounds.height / 2
        
        guard let user = UserController.shared.loadUserProfile(), let userLocation = UserLocationController.shared.fetchUserLocation() else {return}
        
        if user.usertype == UserType.leadCause.rawValue {
            usertypeLabel.text = "Admin"
            createEventButton.isHidden = false
            tableView.isHidden = false
        }
        
        addressLabel.text = "\(userLocation.cityName ?? ""), UT, \(userLocation.zipcode ?? "")"
        fullnameLabel.text = user.fullname
        distanceLabel.text = "\(user.eventDistance) mile radius"
    }
}


// MARK: - Table View Data Source
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
        
        guard let events = EventController.shared.events else {return UITableViewCell()}
        cell.event = events[indexPath.row]
        cell.buttonTag = indexPath.row
        
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
}
