//
//  CustomTabBarViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/12/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpTabBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setUpTabBar() {
        let hamburgerButton: UIButton = UIButton(type: .custom)
        hamburgerButton.setImage(#imageLiteral(resourceName: "Hamburger"), for: .normal)
        hamburgerButton.addTarget(self, action: #selector(configureLocaiton), for: .touchUpInside)
        
        let profileButton: UIButton = UIButton(type: .custom)
        profileButton.setImage(#imageLiteral(resourceName: "ProfilePicture"), for: .normal)
        profileButton.addTarget(self, action: #selector(segueToProfileView), for: .touchUpInside)
        
        let image = #imageLiteral(resourceName: "HappyLogo")
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        
        guard let bannerWidth = navigationController?.navigationBar.frame.size.width, let bannerHeight = navigationController?.navigationBar.frame.size.height else {return}
        happyImage.frame.size.height = bannerHeight / 2
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.titleView = happyImage
    }
    
    
    /// This checks to make sure the user wants to logout
    private func confirmLogoutAlert(completion: @escaping(_ success: Bool) -> Void) {
        
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay, Log Me Out", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(false)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Objective-C Functions
    @objc func configureLocaiton() {
        presentSimpleAlert(viewController: self, title: "Coming Soon!", message: "This feature has not yet been configured yet!")
    }
    
    @objc func segueToProfileView() {
        confirmLogoutAlert { (responce) in
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
