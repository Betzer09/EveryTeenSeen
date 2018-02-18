//
//  Event.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class Event: Codable, Equatable {
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.title == rhs.title && lhs.address == rhs.address && lhs.dateHeld == rhs.dateHeld && lhs.timestamp == rhs.timestamp && lhs.eventInfo == rhs.eventInfo
    }
    
    // MARK: - Properties
    let title: String
    let timestamp: String
    let dateHeld: String
    let userWhoPosted: String
    var attending: Int
    let address: String
    let eventInfo: String
    var photo: Photo? = nil
    
    // MARK: - Init
    init(title: String, timestamp: String = Formatter.ISO8601.string(from: Date()), dateHeld: String, userWhoPosted: String,
         attending: Int = 0, address: String, eventInfo: String) {
        self.title = title
        self.timestamp = timestamp
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
        case timestamp
        case dateHeld = "date_held"
        case userWhoPosted = "user_who_posted"
        case eventInfo = "event_info"
    }
    
}










