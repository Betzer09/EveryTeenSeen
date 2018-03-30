//
//  EventDetailViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/26/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventMeetUpDateLabel: UILabel!
    @IBOutlet weak var eventContentView: UIView!
    @IBOutlet weak var eventSummary: UITextView!
    
    // MARK: - Properties
    var event: Event?

    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
    }
    
    // MARK: - Functions
    private func setUpView() {
        guard let event = event, let imageData = event.photo?.imageData else {return}
        
        eventNameLabel.text = event.title
        eventImageView.image = UIImage(data: imageData)
        eventMeetUpDateLabel.text = event.dateHeld + "\n" + event.eventTime
        eventAddressLabel.text = event.address
        eventSummary.text = event.eventInfo
        eventImageView.layer.cornerRadius = 15
        eventImageView.clipsToBounds = true
    }
}

// MARK: - Set Up Navigation
extension EventDetailViewController {
    
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let backButton: UIButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        profileButton.setImage(#imageLiteral(resourceName: "ProfilePicture"), for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = #imageLiteral(resourceName: "HappyLogo")
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.titleView = happyImage
    }
    
    // MARK: - Objective-C Functions
    @objc func configureLocation() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func segueToProfileView() {
        guard UserController.shared.loadUserProfile() != nil else {
            presentLoginAlert(viewController: self)
            return
        }
        presentUserProfile(viewController: self)
    }
}
