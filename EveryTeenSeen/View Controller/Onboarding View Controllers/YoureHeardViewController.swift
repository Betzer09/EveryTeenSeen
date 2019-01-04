//
//  YoureHeardViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class YoureHeardViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var youreHeardLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        createGradientLayer()
        self.view.bringSubviewToFront(imageView)
        self.view.bringSubviewToFront(youreHeardLabel)
    }
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: -0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1.25)

        let lightGreen = UIColor(red: divideNumberForColorWith(number: 36), green: divideNumberForColorWith(number: 255), blue: divideNumberForColorWith(number: 158), alpha: 0.8)
        let purple = UIColor(red: divideNumberForColorWith(number: 129), green: divideNumberForColorWith(number: 27), blue: divideNumberForColorWith(number: 246), alpha: 1)

        
        gradientLayer.colors = [lightGreen.cgColor, purple.cgColor]
        
        self.view.layer.addSublayer(gradientLayer)
    }


}
