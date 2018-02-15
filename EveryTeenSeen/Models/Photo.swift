//
//  Photo.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/14/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation


class Photo {
    
    // MARK: - Properties
    let image: Data
    let eventTitle: String
    
    @discardableResult init(image: Data, eventTitle: String) {
        self.image = image
        self.eventTitle = eventTitle
    }
    
}
