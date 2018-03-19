//
//  UserProfileViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/17/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

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
    
    // MARK: - Functions 
    private func setUpView() {
        createEventButton.layer.cornerRadius = createEventButton.bounds.height / 2
        
        guard let user = UserController.shared.loadUserFromDefaults(), let userLocation = UserLocationController.shared.fetchUserLocation(), let cityName = userLocation.cityname,
            let distance = user.distance else {return}
        
        if user.userType == UserType.leadCause.rawValue {
            usertypeLabel.text = "Admin"
            createEventButton.isHidden = false
            tableView.isHidden = false
        }
        
        addressLabel.text = "\(cityName), \(userLocation.zipcode ?? "")"
        fullnameLabel.text = user.fullname
        distanceLabel.text = "\(distance)"
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
