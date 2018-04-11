//
//  CustomTabBarViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController {
    
    // MARK: - Current Tab
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTabBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureTabBar() {
        self.tabBar.unselectedItemTintColor = UIColor.black
    }
}
