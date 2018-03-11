//
//  YoureNotAloneViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class YoureNotAloneViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.createGradientLayer()
        self.view.bringSubview(toFront: imageView)
        self.view.bringSubview(toFront: textView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Properties
    var gradientLayer: CAGradientLayer!
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: -0.25)
        gradientLayer.endPoint = CGPoint(x: -0.5, y: 2)
        
        let yellow = UIColor(red: divideNumberForColorWith(number: 255), green: divideNumberForColorWith(number: 200), blue: divideNumberForColorWith(number: 0), alpha: 0.5)
        let purple = UIColor(red: divideNumberForColorWith(number: 89), green: divideNumberForColorWith(number: 39), blue: divideNumberForColorWith(number: 255), alpha: 1)
        
        gradientLayer.colors = [purple.cgColor, yellow.cgColor]
        
        self.view.layer.addSublayer(gradientLayer)
    }


}
