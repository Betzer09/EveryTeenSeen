//
//  Event.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class Event: Codable {
    
    // MARK: - Properties
    let title: String
    let datePosted: Date
    let dateHeld: Date
    let userWhoPosted: User
    let attending: Int
    let zipcode: String
    
    // MARK: - Init
    init(title: String, datePosted: Date = Date(), dateHeld: Date, userWhoPosted: User, attending: Int = 0, zipcode: String) {
        self.title = title
        self.datePosted = datePosted
        self.dateHeld = dateHeld
        self.userWhoPosted = userWhoPosted
        self.attending = attending
        self.zipcode = zipcode
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case attending
        case zipcode
        case datePosted  = "date_posted"
        case dateHeld = "date_held"
        case userWhoPosted = "user_who_posted"
        
    }
    
    
}
