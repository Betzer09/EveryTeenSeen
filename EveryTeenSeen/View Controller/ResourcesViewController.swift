//
//  ResourcesViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class ResourcesViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var backgroundScrollView: UIScrollView!
    @IBOutlet weak var resouresBackgroundImage: UIImageView!
    @IBOutlet weak var downloadUTAAppButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
        setUpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundScrollView.delegate = self
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
}

extension ResourcesViewController {
    /// Configures the navigation bar to have all of the normal stuff
    func configureNavigationBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(configureLocation), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        profileButton.setImage(#imageLiteral(resourceName: "ProfilePicture"), for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = #imageLiteral(resourceName: "HappyLogo")
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
        UserController.shared.confirmLogoutAlert(viewController: self) { (responce) in
            guard responce else {return}
            UserController.shared.signUserOut { (success, error) in
                if let error = error {
                    presentSimpleAlert(viewController: self, title: "Error logging out!", message: "Error description: \(error.localizedDescription)")
                }
                
                // If the user has succesfully logged out.
                guard success else {return}
                
                // Present the login vc
                presentLogoutAndSignUpPage(viewController: self)
                
            }
        }
    }
}

















