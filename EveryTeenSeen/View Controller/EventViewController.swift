//
//  EventViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import Firebase

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var createEventBtn: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    
    
    // MARK: - Properties
    
    // MARK: - View LifeCycles
    override func viewWillAppear(_ animated: Bool) {
        self.setUpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventController.shared.fetchAllEvents()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        confirmLogoutAlert { (responce) in
            guard responce else {return}
            UserController.shared.signUserOut { (success, error) in
                if let error = error {
                    presentSimpleAlert(viewController: self, title: "Error logging out!", message: "Error description: \(error.localizedDescription)")
                }
                
                // If the user has succesfully logged out.
                guard success else {return}
                
                // Present the login vc
                presentLogoutAndSignUpPage(viewController: self)
                
            }
        }
    }
    
    
    // MARK: - TableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: - Fetch the events from firestore
        return EventController.shared.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
        
        guard let events = EventController.shared.events else {NSLog("Error: There are no events!"); return UITableViewCell()}
        
        let event = events[indexPath.row]
        cell.updateCellWith(event: event)
        
        return cell
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height * 0.7
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    
    // MARK: - Views
    private func setUpView() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: EventController.eventWasUpdatedNotifcation, object: nil)
    }
    
    private func loadAllEvents(completion: @escaping (_ success: Bool) -> Void) {
        EventController.shared.fetchAllEvents { (success) in
            guard success else {return}
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            completion(true)
        }
    }

    
    // MARK: - Functions
    
    /// This checks to make sure the user wants to logout
    private func confirmLogoutAlert(completion: @escaping(_ success: Bool) -> Void) {
        
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay, Log Me Out", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setTableViewHeight() {
        tableview.estimatedRowHeight = self.view.bounds.height * 0.7
        tableview.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Objective - C functions
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
}








