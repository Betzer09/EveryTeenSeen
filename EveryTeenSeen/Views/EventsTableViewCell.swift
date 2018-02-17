//
//  EventsTableViewCell.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/15/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    @IBOutlet weak var eventCountLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    
    // MARK: - Actions
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func goingButtonPressed(_ sender: Any) {
    }
    
    // MARK: - Functions
    
    func updateCellWith(event: Event) {
        
        guard let data = event.photo?.image, let image = UIImage(data: data) else {return}
        
        eventPhotoImageView.image = image
        usernameTextField.text = event.userWhoPosted
        eventCountLabel.text = "Attending: \(event.attending)"
        eventDateLabel.text = event.dateHeld
        
        
        
    }

}
