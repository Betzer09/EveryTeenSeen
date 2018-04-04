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
import FirebaseInstanceID
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        self.setUpNavigationBar()
        self.configureUserToSignIn()
        self.setUpNotificationObserver()
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBHandler()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // This is to make sure your bandwidth isn't taken up
        Messaging.messaging().shouldEstablishDirectChannel = false
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    // This runs when the user actually interatacts with the notification, like when the app is open and it comes down, or they interact with it from the lock screen. 
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        print("Push notification received: \(data)")
    }
    
    @objc func refreshToken(notificaiton: NSNotification) {
        guard let refreshToken = InstanceID.instanceID().token() else {return}
        
        print("*** \(refreshToken) ***")
        
        FBHandler()
    }
    
    func FBHandler() {
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
}

extension AppDelegate {
    func setUpNavigationBar() {
        // Navigation Style
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barTintColor = UIColor(red: divideNumberForColorWith(number: 99), green: divideNumberForColorWith(number: 79), blue: divideNumberForColorWith(number: 237), alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    /// This directs the user to the right place
    func configureUserToSignIn() {
        let singInView: UIStoryboard = UIStoryboard(name: "LoginSignUp", bundle: nil)
        let mainView: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let adminView: UIStoryboard = UIStoryboard(name: "Admin", bundle: nil)
        let onboardingView = UIStoryboard(name: "Onboarding", bundle: nil)
        
        var viewController: UIViewController
        
        if UserController.shared.checkIfThereIsACurrentUser(), let user = UserController.shared.loadUserProfile(), let email = user.email {
            UserController.shared.fetchUserInfoFromFirebaseWith(email: email)
            
            // Fetch the user profile picure
            UserController.shared.fetchProfilePicture()
            
            if user.usertype == UserType.joinCause.rawValue {
                // This is a normal user
                viewController = mainView.instantiateInitialViewController()!
            } else if user.usertype == UserType.leadCause.rawValue {
                // This is an admin user
                viewController = adminView.instantiateInitialViewController()!
            } else {
                print("Error: Something is wrong with the usertype of: \(user.usertype ?? "")")
                viewController = mainView.instantiateInitialViewController()!
            }
        } else {
            // This means there is no User at all
            if let _ = UserLocationController.shared.fetchUserLocation()  {
                // If they have a correct location let them sign in
                viewController = singInView.instantiateInitialViewController()!
            } else {
                viewController = onboardingView.instantiateInitialViewController()!
            }
            
        }
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = viewController
    }
    
    func setUpNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notificaiton:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
    }
}
