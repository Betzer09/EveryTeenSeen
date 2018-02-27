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
    let imageData: Data
    let photoPath: String
    
    @discardableResult init(imageData: Data, photoPath: String) {
        self.imageData = imageData
        self.photoPath = photoPath
    }
    
}
