//
//  CustomTabBarViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTabBar()
    }

    func configureTabBar() {
        self.tabBar.unselectedItemTintColor = UIColor.black
//        self.tabBar.barStyle = UIColor(red: 0, green: divideNumberForColorWith(number: 122), blue: divideNumberForColorWith(number: 255), alpha: 1)
    }
}
