//
//  DonationURL.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 4/20/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import FirebaseFirestore

class DonationURL: Codable {
    
    var stringURL: String
    
    init(stringURL: String) {
        self.stringURL = stringURL
    }
    
    enum CodingKeys: String, CodingKey {
        case stringURL = "donation_page_url"
    }
}

class DonationURLController {
    
    static private let donationURLKey = "donation_urls"
    static private let donationURLDocumentID = "donation_page"
    
    static let shared = DonationURLController()
    
    var donationURLString: String?
    
    func fetchDonationURLPage() {
        let db = Firestore.firestore()
        db.collection(DonationURLController.donationURLKey).document(DonationURLController.donationURLDocumentID).getDocument { (snapshot, error ) in
            
            if let error = error {
                NSLog("There was a problem loading the donation URL: \(error.localizedDescription)")
                return
            }
            
            guard let dictionaryData = snapshot?.data(), let data = convertJsonToDataWith(json: dictionaryData) else {return}
            
            do {
                let donationURL = try JSONDecoder().decode(DonationURL.self, from: data)
                self.donationURLString = donationURL.stringURL
            } catch let e {
                NSLog("There was a problem decoding the donatin URL: \(e.localizedDescription)")
            }
        }
    }
}





