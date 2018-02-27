//
//  PhotoController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 2/13/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PhotoController {
    
    static let shared = PhotoController()
    
    // MARK: - Properties
    
    // Create
    func uploadEventImageToStorageWith(image: UIImage, eventTitle: String, completion: @escaping (_ imageURL: String) -> Void,
                                       completionHandler: @escaping (_ success: Bool) -> Void) {
        
        let photoStorage = Storage.storage()
        var storageRef = photoStorage.reference()
        
        guard let data = UIImageJPEGRepresentation(image, 0.25) else {completionHandler(false) ;return}
        
        // Create the file metaData
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        storageRef = storageRef.child("\(eventTitle).png")
        
        
        let uploadTask = storageRef.putData(data, metadata: metadata) { (metadata, error) in
            
            if let error = error as? NSError {
                guard let storageError = StorageErrorCode(rawValue: error.code) else {return}
                switch storageError {
                case .objectNotFound:
                    NSLog("File not found")
                    break
                case .unauthorized:
                    NSLog("User doesn't have permission to upload photo")
                    break
                case .cancelled:
                    NSLog("User canceled the uploaded")
                    break
                case .unknown:
                    NSLog("An Unknown error has occured")
                    break
                default:
                    // a seperate error ocurred this a good place to try uploading again
                    break
                }
            }
            
            guard let imageURL = metadata?.downloadURL()?.absoluteString else {NSLog("Error with imageDownloadURL"); return}
            completion(imageURL)
            completionHandler(true)
            
        }
        
        uploadTask.observe(.success) { (snapshot) in
            NSLog("\'\(eventTitle)\' Uploaded Successfully")
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            guard let progress = snapshot.progress else {return}
            
            let percentComplete = 100.0 * Double(progress.completedUnitCount)
            NSLog("Upload Percentage == \(percentComplete)")
        }
    }
    
    // MARK: - Delete Images From Firebase Storage
    
    func deletingImageFromStorageWith(eventTitle: String, completion: @escaping (_ success: Bool ) -> Void) {
        let storage = Storage.storage()
        var storageRef = storage.reference()
        
        // Create a reference to the file we want to download
        storageRef = storageRef.child("\(eventTitle).png")
        
        storageRef.delete { error in
            if let error = error {
                NSLog("Error deleting image: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func sendPushNotificaton() {
        
    }
}

