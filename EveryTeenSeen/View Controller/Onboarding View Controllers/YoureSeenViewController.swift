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
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    

    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        createGradientLayer()
        self.view.bringSubview(toFront: imageView)
    }
    
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 1)
        
        
//        (x: CGPoint(x: 0, y: 0), y: CGPoint(x: 1, y: 1))
        
        let orange = UIColor(red: divide(number: 255), green: divide(number: 194), blue: divide(number: 0), alpha: 1)
        let purple = UIColor(red: divide(number: 143), green: divide(number: 26), blue: divide(number: 219), alpha: 1)
        
        gradientLayer.colors = [orange.cgColor, purple.cgColor]
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    private func divide(number: Double) -> CGFloat {
        return CGFloat(number / 255.0)
    }

}



















