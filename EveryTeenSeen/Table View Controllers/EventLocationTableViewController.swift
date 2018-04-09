//
//  EventLocationTableViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import MapKit

class EventLocationTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    // MARK: - Properties
    var matchingItems: [MKMapItem] = []
    var address: String?
    var lat: Double = 0.0
    var long: Double = 0.0

    // MARK: - View Life Cycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressSearchBar.sizeToFit()
        addressSearchBar.placeholder = "Search For Places"
        configureNavigationBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: addressSearchBar) { (results) in
            self.matchingItems = results
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventLocationCell", for: indexPath)
        
        let location = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: location)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = matchingItems[indexPath.row].placemark
        guard let name = location.name else {return}
        address = "\(name), \(parseAddress(selectedItem: location))"
        self.lat = location.coordinate.latitude
        self.long = location.coordinate.longitude
        
        self.performSegue(withIdentifier: "unwindToCreateEventVC", sender: nil)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToCreateEventVC" {
            guard let vc = segue.destination as? CreateEventViewController else {return}
            vc.address = address
            vc.lat = self.lat
            vc.long = self.long
        }
    }
}

extension EventLocationTableViewController {
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        self.navigationItem.title = "Search Locations"
    }
    
    
    @objc func backButtonPressed() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
