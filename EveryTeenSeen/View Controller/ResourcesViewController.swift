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
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        configureButtonWith(button: downloadUTAAppButton)
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
