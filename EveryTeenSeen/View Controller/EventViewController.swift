//
//  EventViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var createEventBtn: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
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
    
    // MARK: - Table View Function
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    
    // MARK: - Views
    
    
    // MARK: - Functions
    

    
    // MARK: - Objective - C functions

}
