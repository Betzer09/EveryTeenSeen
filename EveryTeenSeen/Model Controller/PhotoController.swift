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
    func uploadImageToStorageWith(image: UIImage, photoTitle: String, completion: @escaping (_ imageURL: String) -> Void, completionHandler: @escaping (_ success: Bool) -> Void = {_ in}) {
        
        let photoStorage = Storage.storage()
        var storageRef = photoStorage.reference()
        
        guard let data = image.jpegData(compressionQuality: 0.25) else {completionHandler(false) ;return}
        
        // Create the file metaData
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        storageRef = storageRef.child("\(photoTitle).png")
        
        
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
            
            storageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    debugPrint(error)
                    completionHandler(false)
                    return
                }
                
                guard let url = url?.absoluteURL else {return}
                completion("\(url)")
                completionHandler(true)
            })
            
        }
        
        uploadTask.observe(.success) { (snapshot) in
            NSLog("\'\(photoTitle)\' Uploaded Successfully")
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            guard let progress = snapshot.progress else {return}
            
            let percentComplete = 100.0 * Double(progress.completedUnitCount)
            NSLog("Upload Percentage == \(percentComplete)")
        }
    }
    
    // MARK: - Delete Images From Firebase Storage
    
    /// Deletes the image from firebase storate
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
    
    func fetchUserProfileImage(completion: @escaping(_ success: UIImage?, _ success: Bool) -> Void = {_,_  in}) {
        guard let user = UserController.shared.loadUserProfile(), let photoURL = user.profileImageURLString else {return}
        
        guard let url = URL(string: photoURL) else {NSLog("Error fetching User's profile picture becasue of user!: userProfileURL =  \(photoURL)"); completion(nil, false); return}
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                NSLog("Error downloading profile picture due to: \(error.localizedDescription)")
                completion(nil, false)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {NSLog("Error with profile picture data for user: \(user.email ?? "")"); return}
            completion(image, true)
        }.resume()
        
    }
}
