//
//  OnboardingViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/10/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    //UIPageViewControllerDelegate, UIPageViewControllerDataSource
    
    // MARK: - Properties
    var pageControl = UIPageControl()
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.dataSource = self
//        self.delegate = self
    }

    // MARK: - Page Controller Delegate Methods
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//
//    }

    // MARK: - Functions
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }

}
