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
    let eventTime: String
    let userWhoPosted: String
    var attending: [String]? = []
    let address: String
    let eventInfo: String
    var photoURL: String? = ""
    var photo: Photo? = nil
    var reports: [[String: String]]? = [[:]]
    var lat: Double? = 0
    var long: Double? = 0
    
    // MARK: - Init
    init(title: String, timestamp: String = "\(Date())", dateHeld: String, userWhoPosted: String,
         attending: [String] = [] , address: String, eventInfo: String, eventTime: String, reports: [[String: String]] = []) {
        self.title = title
        self.timestamp = timestamp
        self.dateHeld = dateHeld
        self.userWhoPosted = userWhoPosted
        self.attending = attending
        self.eventTime = eventTime
        self.address = address
        self.eventInfo = eventInfo
        self.reports = reports
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case attending
        case address
        case timestamp
        case reports
        case eventTime = "event_time"
        case dateHeld = "date_held"
        case userWhoPosted = "user_who_posted"
        case eventInfo = "event_info"
        case photoURL = "photo_url"
        case lat
        case long
    }
}
