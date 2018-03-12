//
//  EventsTableViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.loadAllEvents()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventsTableViewCell else {return UITableViewCell()}
        
        guard let events = EventController.shared.events else {return UITableViewCell()}
        cell.event = events[indexPath.row]
        
        cell.layer.cornerRadius = 15
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventController.shared.events?.count ?? 0
    }
    
    // MARK: - Table View Fnctions
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.bounds.height * 0.62
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
            }
            completion(true)
        }
    }

    
    // MARK: - Objective-C Functions
    @objc func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}





