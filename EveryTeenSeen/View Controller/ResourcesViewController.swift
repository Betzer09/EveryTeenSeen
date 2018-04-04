//
//  ResourcesViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class ResourcesViewController: UIViewController {
    
    @IBOutlet weak var resouresBackgroundImage: UIImageView!
    @IBOutlet weak var downloadUTAAppButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        setUpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNotificationObservers()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

    // MARK: - Actions
    @IBAction func downloadUTAAppButtonPressed(_ sender: Any) {
        
        alertTheUserToBeRedirected { (answer) in
            guard answer else {return}
            let urlStr = "https://itunes.apple.com/us/app/safeut/id1052510262?mt=8"
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(URL(string: urlStr)!)
            }
        }
    }
    
    // MARK: - Configure View
    func setUpView() {
        createGradientLayerWith(startpointX: -1, startpointY: -1, endpointX: 2, endPointY: 2, firstRed: 255, firstGreen: 194, firstBlue: 0, firstAlpha: 1, secondRed: 143, secondGreen: 26, secondBlue: 219, secondAlpha: 1, viewController: self)
    }
    
    func setUpNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfilePicture), name: UserController.shared.profilePictureWasUpdated, object: nil)
    }
    
    func alertTheUserToBeRedirected(completion: @escaping(_ wantToRedirect: Bool) -> Void) {
        let alert = UIAlertController(title: "View In Appstore?", message: "You are about to be redirect to the appstore to see the Safe UT app.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Go to Appstore", style: .default) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            completion(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Objective - C Functions
    @objc func reloadProfilePicture() {
        NSLog("Profile picture has been updated")
        
        guard let unwrappedImage = UserController.shared.profilePicture.circleMasked else {return}
        let profileImage = resizeImage(image: unwrappedImage , targetSize: CGSize(width: 40.0, height: 40.0))
        let profileButton: UIButton = UIButton(type: .custom)
        let profilePicutre = resizeImage(image: profileImage, targetSize: CGSize(width: 40.0, height: 40.0))
        profileButton.setImage(profilePicutre, for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        }
    }
}

extension ResourcesViewController {
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        guard let unwrappedImage = UserController.shared.profilePicture.circleMasked else {return}
        let profileImage = resizeImage(image: unwrappedImage, targetSize: CGSize(width: 40.0, height: 40.0))
        
        profileButton.setImage(profileImage, for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = resizeImage(image: #imageLiteral(resourceName: "HappyLogo"), targetSize: CGSize(width: 40.0, height: 40.0))
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.titleView = happyImage
    }
    
    // MARK: - Objective-C Functions
    @objc func configureLocation() {
        presentSimpleAlert(viewController: self, title: "Coming Soon!", message: "This feature has not yet been configured yet!")
    }
    
    @objc func segueToProfileView() {
        guard UserController.shared.loadUserProfile() != nil else {
            presentLoginAlert(viewController: self)
            return
        }
        presentUserProfile(viewController: self)    }
}

















