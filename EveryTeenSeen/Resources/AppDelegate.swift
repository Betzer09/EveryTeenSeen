//
//  AppDelegate.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/1/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let signInView: UIStoryboard = UIStoryboard(name: "LoginSignUp", bundle: nil)
        let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UIViewController
        
        if let user = UserController.shared.loadUserFromDefaults() {
            if user.userType == UserType.joinCause.rawValue  || user.userType == UserType.leadCause.rawValue{
                // This is a normal user
                viewController = mainView.instantiateInitialViewController()!
            } else {
                print("Error: Something is wrong with the usertype of: \(user.userType)")
                viewController = mainView.instantiateInitialViewController()!
            }
        } else {
            // This means there is no User at all
            viewController = signInView.instantiateViewController(withIdentifier: "loginVC")
        }
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = viewController
        
        EventController.shared.fetchAllEvents()
        return true
    }



}

