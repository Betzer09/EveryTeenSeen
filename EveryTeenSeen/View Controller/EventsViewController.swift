//
//  EventsTableViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.loadAllEvents { (success) in
            guard success else {return}
            self.checkIfUserHasAccount()
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindToEventsVC(segue: UIStoryboardSegue){}
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

    // MARK: - Set Up View
    private func setUpView() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: EventController.eventWasUpdatedNotifcation, object: nil)
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
}

// MARK: - Table View Delegate
extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
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

// MARK: - Navigation Bar
extension EventsViewController {
    
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        profileButton.setImage(#imageLiteral(resourceName: "ProfilePicture"), for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = #imageLiteral(resourceName: "HappyLogo")
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
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





