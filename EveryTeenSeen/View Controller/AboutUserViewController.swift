//
//  AboutUserViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/4/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class AboutUserViewController: UIViewController {
    
    // MARK: - Propertes
    let firebaseManger = FirebaseManager()
    var email: String? {
        didSet {
            self.configureView()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var userProfilePictureView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var interestsStackView: UIStackView!
    
    // LoadingContentsView
    @IBOutlet weak var loadingContentsView: UIView!
    @IBOutlet weak var loadingContentsIndicator: UIActivityIndicatorView!
    
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Functions
    func configureView() {
        guard let email = email else {return}
        
        firebaseManger.fetchOtherUserFromFirebase(email: email) { (user, error) in
            if let error = error {
                NSLog("Error present user information for email: \(email) with error: \(error.localizedDescription)")
                
                presentSimpleAlert(viewController: self, title: "There was a problem fetching this user!", message: "")
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            guard let user = user else {return}
            
            self.firebaseManger.fetchProfilePicureWith(string: user.profileImageURLString, completion: { (image) in
                guard let image = image else {return}
                DispatchQueue.main.async {
                    self.userProfilePictureView.image = image
                    self.usernameLabel.text = user.fullname
                    self.addressLabel.text = user.zipcode
                    
                    self.loadingContentsView.isHidden = true
                    self.loadingContentsIndicator.isHidden = true
                    self.loadingContentsIndicator.stopAnimating()
                    
                    configureAllButtonsIn(view: self.interestsStackView, interests: user.interests)
                }
            })
        }
    }
}

// MARK: - Set Up Navigation 
extension AboutUserViewController {
    
    func configureNavigationBar() {
        let backButton: UIButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let image = resizeImage(image: #imageLiteral(resourceName: "HappyLogo"), targetSize: CGSize(width: 40.0, height: 40.0))
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = happyImage
    }
    
    // MARK: - Objective-C Functions
    @objc func configureLocation() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
