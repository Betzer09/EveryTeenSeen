//
//  DonateNowViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/9/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class DonateNowViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var donateView: UIWebView!
    @IBOutlet weak var loadingWebActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingGroupView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingWebActivityIndicator.startAnimating()
        configureNavBar()
    }
    
    override func viewDidLoad() {
        fetchDonateNowPage()
    }
    
    // MARK: - Actions
    @IBAction func refreshWebContentButtonPressed(_ sender: Any) {
        fetchDonateNowPage()
    }
    @IBAction func backButtonForWebView(_ sender: Any) {
        self.donateView.goBack()
    }
    
    // MARK: - Fucntions

    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadingGroupView.isHidden = true
        self.loadingWebActivityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        NSLog("Error loading donation page: \(error.localizedDescription)")
        presentSimpleAlert(viewController: self, title: "There was a problem loading the page!", message: "")
    }
    
    func fetchDonateNowPage() {
        
        self.loadingGroupView.isHidden = false
        self.loadingWebActivityIndicator.stopAnimating()
        
        guard let url = URL(string: "https://www.paypal.me/EveryTeenSeen") else {
            return
        }
        
        DispatchQueue.main.async {
            self.donateView.loadRequest(URLRequest(url: url))
        }
    }
    
    func configureNavBar() {
        let image = resizeImage(image: #imageLiteral(resourceName: "HappyLogo"), targetSize: CGSize(width: 40.0, height: 40.0))
        let happyImage: UIImageView = UIImageView(image: image)
        happyImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = happyImage
    }
}
