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
    
    // MARK: - Properties
    var buttonTag: Int?
    
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
    @IBAction func goingButton(_ sender: Any) {
      
        guard let indexPath = buttonTag,
            let user = UserController.shared.loadUserFromDefaults(),
            let rootvc = UIApplication.shared.keyWindow?.rootViewController,
            let event = EventController.shared.events?[indexPath],
            let count = event.attending?.count else {return}
        
        if goingLabel.text == "Going?" {
            configureLableAsNotGoing()
            eventAttendingLabel.text = "Attending: \(count + 1)"
            
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: true, completion: { (stringError) in
                guard let error = stringError else {return}
                presentSimpleAlert(viewController: rootvc, title: "Unable to attend event", message: error)
            })
            
        } else {
            configureLabelAsGoing()
            // This shows that there are zero attending
            if count <= 0 {
                eventAttendingLabel.text = "Attending: \(count)"
            } else {
                eventAttendingLabel.text = "Attending: \(count - 1)"
            }
            
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: false, completion: { (stringError) in
                guard let error = stringError else {return}
                presentSimpleAlert(viewController: rootvc, title: "Unable to attend event", message: error)
            })
        }
    }
    
    // MARK: - Functions
    
    func updateUI() {
        guard let event = event,
            let data = event.photo?.imageData,
            let image = UIImage(data: data),
            let user = UserController.shared.loadUserFromDefaults(),
            let attending = event.attending else {return}
        
        if attending.contains(user.email) {
            configureLableAsNotGoing()
        } else {
            configureLabelAsGoing()
        }
        
        eventPhotoImageView.image = image
        eventAddressLabel.text = event.address
        eventAttendingLabel.text = "Attending: \(attending.count)"
        eventTitleLabel.text = event.title
        eventDateLabel.text = event.dateHeld + "\n" + event.eventTime
    }
    
    func configureLabelAsGoing() {
        goingLabel.text = "Going?"
    }
    
    func configureLableAsNotGoing() {
        goingLabel.text = "Not Going"
    }
}
