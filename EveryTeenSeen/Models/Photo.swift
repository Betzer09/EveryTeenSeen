//
//  Photo.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation

class Photo {
    
    // MARK: - Properties
    let title: String
    var data: Data?
    
    init(title: String, data: Data) {
        self.title = title
        self.data = data
    }
    
}
