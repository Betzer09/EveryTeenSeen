//
//  GetStartedViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class GetStartedViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var viewBehindTheButton: UIView!
    @IBOutlet weak var backgroundLayer: UIView!
    
    
    // MARK: - View LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        getStartedButton.layer.cornerRadius = 25
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createGradientLayer()
    }
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: -0.25, y: 0.75)
        
        let lightBlue = UIColor(red: divideNumberForColorWith(number: 76), green: divideNumberForColorWith(number: 159), blue: divideNumberForColorWith(number: 255), alpha: 1.0)
        let purple = UIColor(red: divideNumberForColorWith(number: 146), green: divideNumberForColorWith(number: 29), blue: divideNumberForColorWith(number: 255), alpha: 0.5)
        
        gradientLayer.colors = [lightBlue.cgColor, purple.cgColor]
        
        self.backgroundLayer.layer.addSublayer(gradientLayer)
        self.view.sendSubview(toBack: backgroundLayer)
    }
    


}
