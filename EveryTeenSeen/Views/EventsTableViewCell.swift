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
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventAttendingLabel: UILabel!
    @IBOutlet weak var goingLabel: UILabel!
    
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    
    var event: Event? {
        didSet {
            self.updateUI()
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        
        set(newFrame) {
            let inset: CGFloat = 15
            var frame = newFrame
            frame.origin.x += inset
            frame.size.width -= 2 * inset
            super.frame = frame
        }
    }
    
    // MARK: - Actions
    @IBAction func goingButton(_ sender: UIButton) {
//        let indexPath = IndexPath(row: sender.tag, section: 1)
//
//        guard let event = EventController.shared.events?[indexPath.row] else {return}
//        EventController.shared.isPlanningOnAttending(event: event, wantsToJoin: true) { (errorString) in
//            guard errorString != nil else {return}
//            NSLog(errorString!)
//        }
        
    }
    
    
    
    // MARK: - Functions
    
    func updateUI() {
        guard let event = event, let data = event.photo?.imageData, let image = UIImage(data: data) else {return}
        
        eventPhotoImageView.image = image
        eventAddressLabel.text = event.address
        eventAttendingLabel.text = "Attending: \(event.attending)"
        eventDateLabel.text = event.dateHeld
        eventTitleLabel.text = event.title
    }
    
    

}
