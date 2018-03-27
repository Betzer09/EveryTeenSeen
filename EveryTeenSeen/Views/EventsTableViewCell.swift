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
        
        guard let rootvc = UIApplication.shared.keyWindow?.rootViewController else {return}
        guard let user = UserController.shared.loadUserProfile(),
            let eventPassedInToCell = event,
            let indexPath = EventController.shared.events?.index(of: eventPassedInToCell),
            let event = EventController.shared.events?[indexPath],
            let count = event.attending?.count else {return}
        

        if goingLabel.text == "Going?" {
            configureLableAsNotGoing()
        
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: true, completion: { (stringError) in
                guard let error = stringError else {
                    // This means there is no error update label
                    return
                }
                presentSimpleAlert(viewController: rootvc, title: "Unable to attend event", message: error)
            }, completionHandler: { (updatedEvent) in
                guard let updatedEvent = updatedEvent, let updatedCount = updatedEvent.attending?.count else {return}
                self.eventAttendingLabel.text = "Attending: \(updatedCount)"
            })
        } else {
            configureLabelAsGoing()
            // This shows that there are zero attending
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: false, completion: { (stringError) in
                guard let error = stringError else {
                    self.eventAttendingLabel.text = "Attending: \(count)"
                    return
                }
                presentSimpleAlert(viewController: rootvc, title: "Unable to attend event", message: error)
            }, completionHandler: {(updatedEvent) in
                guard let updatedEvent = updatedEvent, let updatedCount = updatedEvent.attending?.count else {return}
                self.eventAttendingLabel.text = "Attending: \(updatedCount)"
            })
        }
    }
    
    // MARK: - Functions
    func updateUI() {
        guard let event = event,
            let data = event.photo?.imageData,
            let image = UIImage(data: data),
            let attending = event.attending else {return}
        
        if let user = UserController.shared.loadUserProfile() {
            if attending.contains(user.email) {
                configureLableAsNotGoing()
            } else {
                configureLabelAsGoing()
            }
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












