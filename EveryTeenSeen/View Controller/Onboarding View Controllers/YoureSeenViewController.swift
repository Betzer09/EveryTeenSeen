//
//  YoureSeenViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class YoureSeenViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var youreSeenLabel: UILabel!
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    

    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createGradientLayer()
        self.view.bringSubview(toFront: imageView)
        self.view.bringSubview(toFront: youreSeenLabel)
    }
    
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 1)
        
    
        
        let orange = UIColor(red: divideNumberForColorWith(number: 255), green: divideNumberForColorWith(number: 194), blue: divideNumberForColorWith(number: 0), alpha: 1)
        let purple = UIColor(red: divideNumberForColorWith(number: 143), green: divideNumberForColorWith(number: 26), blue: divideNumberForColorWith(number: 219), alpha: 1)
        
        gradientLayer.colors = [orange.cgColor, purple.cgColor]
        
        self.view.layer.addSublayer(gradientLayer)
    }

}



















