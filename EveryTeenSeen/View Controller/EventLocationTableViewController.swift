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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressSearchBar.sizeToFit()
        addressSearchBar.placeholder = "Search For Places"
        navigationItem.title = "Search Locations"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: addressSearchBar)
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
    
    // MARK: - Functions
    func updateSearchResults(for searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else {return}
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        
        guard let location = UserLocationController.shared.fetchUserLocation() else {return}
        let clLocationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        // With in a 5 mile span both ways
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(clLocationCoordinate, 1000, 1000)
        request.region = MKCoordinateRegionMake(clLocationCoordinate, coordinateRegion.span)
        
        let search = MKLocalSearch(request: request)
        search.start { (results, error) in
            if let error = error {
                NSLog("Error searching for locations: \(error.localizedDescription)")
            }
            
            guard let results = results else {return}
            
            self.matchingItems = results.mapItems
            self.tableView.reloadData()
            
        }
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}
