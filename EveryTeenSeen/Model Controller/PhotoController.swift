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
    var photosGroupDownloadCount: Int = 0 {
        didSet {
            NSLog("Image Count: \(photosGroupDownloadCount)")
        }
    }
    
    // Create
    func uploadEventImageToStorageWith(image: UIImage, eventTitle: String) {
        
        let photoStorage = Storage.storage()
        var storageRef = photoStorage.reference()
        
        guard let data = UIImagePNGRepresentation(image) else {return}
        
        // Create the file metaData
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        storageRef = storageRef.child("\(eventTitle).png")
        
        let uploadTask = storageRef.putData(data, metadata: metadata)
        
        // Watch for errors
        uploadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error as? NSError {
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
    
    private func downloadImageFromStorageWith(eventTitle: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let photoStorage = Storage.storage()
        var storageRef = photoStorage.reference()
        
        // Create a reference to the file we want to download
        storageRef = storageRef.child("\(eventTitle).png")
        
        // Start the download (in this case writing to a file)
        
        let downloadTask = storageRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                NSLog("Error downloaded image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {return}
            let image = UIImage(data: data)
            completion(image)
            
        }
        
        // Errors only occur in the "Failure" case
        downloadTask.observe(.failure) { snapshot in
            
            if let error = snapshot.error as? NSError {
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

        }
        
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
        }
        
        downloadTask.observe(.success) { snapshot in
            NSLog("\'\(eventTitle).png\' complete!")
        }
        
    }
    
    func downloadAllEventImages(events: [Event], completion: @escaping (_ success: Bool) -> Void) {
        let downloadGroup = DispatchGroup()
        
        for event in events {
            downloadGroup.enter()
            photosGroupDownloadCount += 1
            
            downloadImageFromStorageWith(eventTitle: event.title, completion: { (image) in
                guard let image = image, let data = UIImagePNGRepresentation(image) else {
                    NSLog("Error: There is no image!")
                    downloadGroup.leave()
                    self.photosGroupDownloadCount -= 1
                    return
                }
                
                // Create an image
                let photo = Photo(image: data, eventTitle: event.title)
                event.photo = photo
            })
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completion(true)
        }
        
    }
    
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

}

