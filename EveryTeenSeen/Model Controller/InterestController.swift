//
//  InterestController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/19/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import CoreData

class InterestController {
    static let shared = InterestController()
    
    var fetchedResultsController: NSFetchedResultsController<Interest>!
    
    func createInterest(name: String) {
        Interest(name: name)
        UserController.shared.saveToPersistentStore()
    }
    
    func delete(interest: Interest) {
        guard let moc = interest.managedObjectContext else {return}
        moc.delete(interest)
        UserController.shared.saveToPersistentStore()
    }
}
