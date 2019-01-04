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
    @IBOutlet weak var attendingLabel: UILabel!
    @IBOutlet weak var plusButtonImage: UIImageView!
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    @IBOutlet weak var attendEventButton: UIButton!
    
    // MARK: - Properties
    
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
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        guard let rootvc = UIApplication.shared.keyWindow?.rootViewController else {return}
        guard let _ = UserController.shared.loadUserProfile() else {
            presentLoginAlert(viewController: rootvc)
            return
        }
        presentReportEventAlert { (wantsToReport) in
            guard wantsToReport, let event = self.event else {return}
            self.presentAddMessageAlertWith(title: "Reporting \(event.title)", message: "Add a brief message explaining the problem.")
        }
    }
    
    @IBAction func attendEventButtonPressed(_ sender: Any) {
        self.attendEventButton.isEnabled = false
        guard let rootvc = UIApplication.shared.keyWindow?.rootViewController else {return}
        guard let user = UserController.shared.loadUserProfile(),
            let eventPassedInToCell = event,
            let indexPath = EventController.shared.events?.index(of: eventPassedInToCell),
            let event = EventController.shared.events?[indexPath],
            let attending = event.attending else {return}
        
        if attendingLabel.text == "Attend" {
            configureLableAsNotGoing()
        
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: true, completion: { (stringError) in
                guard let error = stringError else {
                    // This means there is no error update label
                    self.attendEventButton.isEnabled = true
                    return
                }
                presentSimpleAlert(viewController: rootvc, title: "Unable to attend event.", message: error)
            }, completionHandler: { (updatedEvent) in
                guard let updatedEvent = updatedEvent, let updatedCount = updatedEvent.attending?.count else {return}
                event.attending = updatedEvent.attending
                self.eventAttendingLabel.text = "Attending: \(updatedCount)"
            })
            self.attendEventButton.isEnabled = true
        } else {
            configureLabelAsGoing()
            // This shows that there are zero attending
            EventController.shared.isPlanningOnAttending(event: event, user: user, isGoing: false, completion: { (stringError) in
                guard let error = stringError else {
                    self.eventAttendingLabel.text = "Attending: \(attending.count)"
                    self.attendEventButton.isEnabled = true
                    return
                }
                presentSimpleAlert(viewController: rootvc, title: "Unable to attend event", message: error)
            }, completionHandler: {(updatedEvent) in
                guard let updatedEvent = updatedEvent, let updatedCount = updatedEvent.attending?.count else {return}
                event.attending = updatedEvent.attending
                self.eventAttendingLabel.text = "Attending: \(updatedCount)"
            })
            self.attendEventButton.isEnabled = true
        }
    }
    
    // MARK: - Functions
    func updateUI() {
        guard let event = event,
            let data = event.photo?.imageData,
            let image = UIImage(data: data),
            let attending = event.attending else {return}
        
        if let user = UserController.shared.loadUserProfile(), let email = user.email {
            if attending.contains(email) {
                configureLableAsNotGoing()
            } else {
                configureLabelAsGoing()
            }
        }
        
        eventPhotoImageView.layer.cornerRadius = 20
        eventPhotoImageView.clipsToBounds = true
        eventPhotoImageView.image = image
        eventAddressLabel.text = event.address
        eventAttendingLabel.text = "Attending: \(attending.count)"
        eventTitleLabel.text = event.title
        eventDateLabel.text = formatStringDateForEventTimeAsString(string: event.dateHeld) + "\n" + event.eventTime
    }
    
    func configureLabelAsGoing() {
        attendingLabel.text = "Attend"
        DispatchQueue.main.async {
            self.plusButtonImage.image = #imageLiteral(resourceName: "plus")
        }

    }
    
    func configureLableAsNotGoing() {
        attendingLabel.text = "Unattend"
        DispatchQueue.main.async {
            self.plusButtonImage.image = #imageLiteral(resourceName: "minus")
        }
    }
    
    func presentAddMessageAlertWith(title: String, message: String) {
        guard let rootvc = UIApplication.shared.keyWindow?.rootViewController, let email = UserController.shared.loadUserProfile()?.email, let event = event else {return}
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let textView = UITextView()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let controller = UIViewController()
        
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        
        alert.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: rootvc.view.frame.height * 0.5)
        alert.view.addConstraint(height)
        
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor.darkBlueAlertColor
        alert.view.bringSubviewToFront(subview)
        
        alert.view.tintColor = UIColor.black
        
        
        alert.setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        
        alert.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            EventController.shared.reportEventWith(userEmail: email, message: textView.text, event: event, completion: { (success) in
                presentSimpleAlert(viewController: rootvc, title: "You have successfully reported this event.", message: "")
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        
        rootvc.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - report alert
    private func presentReportEventAlert(completion: @escaping (_ success: Bool) -> Void) {
        guard let rootvc = UIApplication.shared.keyWindow?.rootViewController, let event = event else {return}
        let alert = UIAlertController(title: "Do you wish to report: \(event.title)?", message: "", preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report Event", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        rootvc.present(alert, animated: true, completion: nil)
    }
    
}
