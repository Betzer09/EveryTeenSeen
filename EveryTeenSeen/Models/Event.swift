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
    let userWhoPosted: String
    let attending: Int
    let address: String
    let eventInfo: String
    
    // MARK: - Init
    init(title: String, datePosted: Date = Date(), dateHeld: Date, userWhoPosted: String,
         attending: Int = 0, address: String, eventInfo: String) {
        self.title = title
        self.datePosted = datePosted
        self.dateHeld = dateHeld
        self.userWhoPosted = userWhoPosted
        self.attending = attending
        self.address = address
        self.eventInfo = eventInfo
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case attending
        case address
        case datePosted  = "date_posted"
        case dateHeld = "date_held"
        case userWhoPosted = "user_who_posted"
        case eventInfo = "event_info"
    }
    
    
}
