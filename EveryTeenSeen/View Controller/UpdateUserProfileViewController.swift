//
//  UpdateUserProfileViewController.swift
//  EveryTeenSeen
//
//  Created by Austin Betzer on 3/26/18.
//  Copyright © 2018 Austin Betzer. All rights reserved.
//

import UIKit

class UpdateUserProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullnameTextfield: UITextField!
    @IBOutlet weak var maxLabelTextField: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var areYouAnAdminLabel: UILabel!
    @IBOutlet weak var activateAdminAccountButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var youAreAnAdminLabel: UILabel!
    
    
    // Admin Group View Outlets
    @IBOutlet weak var activateAdminGroupView: UIView!
    @IBOutlet weak var adminPasswordTextfield: UITextField!
    @IBOutlet weak var incorrectPasswordMessage: UILabel!
    
    // Updated Profile View
    @IBOutlet weak var finishedUpdatedProfileView: UIView!
    @IBOutlet weak var uploadingUpdatedProfileLabel: UILabel!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var exitProfileUpdateView: UIButton!
    @IBOutlet weak var uploadingProfileActivityMonitor: UIActivityIndicatorView!
    
    // User Interest Outlets
    @IBOutlet weak var interestGroupView: UIStackView!
    
    // Success Group view
    @IBOutlet weak var successGroupView: UIView!
    
    // MARK: - Properties
    var delegate: PhotoSelectedViewControllerDelegate?
    private var changedProfilePicture = false
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        configureAllButtonsIn(view: interestGroupView)
    }
    
    // MARK: - Actions
    
    @IBAction func deleteInterestButtonPressed(_ sender: UIButton) {
        self.presentDeleteInterestConformationAlert { (delete) in
            guard delete,
                let interests = UserController.shared.loadUserProfile()?.interests?.array as? [Interest],
                let interestName = sender.titleLabel?.text,
                let indexOfInterest = interests.index(where: { $0.name == interestName } ) else {return}
            
            let interest = interests[indexOfInterest]
            
            InterestController.shared.delete(interest: interest)
            
            configureAllButtonsIn(view: self.interestGroupView)
        }
    }
    
    @IBAction func activateAdminAccountButtonPressed(_ sender: Any) {
        self.fadeActivateAdminGroupIn()
        
        activateAdminAccountButton.isHidden = true
        areYouAnAdminLabel.isHidden = true
        incorrectPasswordMessage.isHidden = true
        adminPasswordTextfield.text = ""
        cameraButton.isHidden = true
        profileImageView.isHidden = true
    }
    
    @IBAction func chooseProfileImageButtonPressed(_ sender: Any) {
        self.presentCameraAndPhotoLibraryOption()
    }
    
    
    @IBAction func dismissActivateAdminGroupButtonPressed(_ sender: Any) {
        self.activateAdminGroupView.isHidden = true
        areYouAnAdminLabel.isHidden = false
        activateAdminAccountButton.isHidden = false
        cameraButton.isHidden = false
        profileImageView.isHidden = false
        
        self.fadeActivateAdminGroupOut()
        view.endEditing(true)
    }
    
    @IBAction func dismissSuccessAdminView(_ sender: Any) {
        guard let user = UserController.shared.loadUserProfile() else {return}
        
        if user.usertype == UserType.leadCause.rawValue {
            presentAdminTabBarVC(viewController: self)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func doneEditingProfileButtonPressed(_ sender: Any) {
        guard let image = profileImageView.image?.circleMasked,
            let fullname = fullnameTextfield.text,
            let user = UserController.shared.loadUserProfile(),
            let email = user.email else {
                NSLog("Error updating user profile!")
                presentSimpleAlert(viewController: self, title: "Oops", message: "There was a problem updating your profile!")
                return
        }

        updateProfileWith(user: user, image: image, email: email, fullname: fullname)
    }
    
    @IBAction func sumbitAdminPasswordButtonPressed(_ sender: Any) {
        guard let password = adminPasswordTextfield.text else {return}
        
        UserController.shared.confirmAdminPasswordWith(password: password ) { (success) in
            if success {
                guard let user = UserController.shared.loadUserProfile(),
                    let email = user.email,
                    let fullname = self.fullnameTextfield.text,
                    let image = self.profileImageView.image else {return}
                self.updateProfileWith(user: user, image: image, email: email, fullname: fullname)
                self.successGroupView.isHidden = false
            } else {
                self.incorrectPasswordMessage.isHidden = false
                self.adminPasswordTextfield.text = ""
            }
        }
    }
    
    @IBAction func sliderValuedChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.maxLabelTextField.text = "\(Int(sender.value)) mi"
        }
    }
    
    // MARK: - Update User Profile Functions
    func updateProfileWith(user: User, image: UIImage, email: String, fullname: String) {
        
        DispatchQueue.main.async {
            self.finishedUpdatedProfileView.isHidden = false
            self.uploadingProfileActivityMonitor.isHidden = false
            self.uploadingProfileActivityMonitor.startAnimating()
        }
        
        if changedProfilePicture == true {
            updateUserProfileImageWith(user: user, image: image, email: email, completion: { (hasFinishedPostingImage) in
                DispatchQueue.main.async {
                    self.successImageView.isHidden = false
                    self.uploadingUpdatedProfileLabel.text = "You've succesfully updated your profile!"
                    self.uploadingProfileActivityMonitor.isHidden = true
                    self.uploadingProfileActivityMonitor.stopAnimating()
                    self.exitProfileUpdateView.isHidden = false
                }
                
                PhotoController.shared.fetchUserProfileImage(completion: { (image, success) in
                    guard success else {return}
                    UserController.shared.profilePicture = image
                })
            })
        } else {
            updateUserProfileWithoutImage(user: user, email: email, fullname: fullname)
            
            DispatchQueue.main.async {
                self.successImageView.isHidden = false
                self.uploadingUpdatedProfileLabel.text = "You've succesfully updated your profile!"
                self.uploadingProfileActivityMonitor.stopAnimating()
                self.exitProfileUpdateView.isHidden = false
            }
        }
    }
    
    func updateUserProfileWithoutImage(user: User, email: String, fullname: String) {
        guard let usertype = user.usertype,
            let profileURL = user.profileImageURLString else {
                presentSimpleAlert(viewController: self, title: "Oops", message: "There was a problem updating your profile!")
                return
        }
        
        UserController.shared.updateUserProfileWith(user: user, fullname: fullname, profileImageURL: profileURL, maxDistance: Int64(distanceSlider.value), usertype: usertype)
    }
    
    func updateUserProfileImageWith(user: User, image: UIImage, email: String, completion: @escaping(_ doneUploadingProfilePicture: Bool) -> Void) {
        
        // Make sure it isn't the default image first
        if profileImageView.image != #imageLiteral(resourceName: "largeAvatar") {
            PhotoController.shared.deletingImageFromStorageWith(eventTitle: email, completion: { (success) in
                guard let fullname = self.fullnameTextfield.text, let usertype = user.usertype else {return}
                
                PhotoController.shared.uploadImageToStorageWith(image: image, photoTitle: "\(email)profile_picture", completion: { (userProfilePictureURL) in
                    guard userProfilePictureURL != "" else {
                        NSLog("Error updating profile image!")
                        completion(false)
                        return
                    }
                    
                    UserController.shared.updateUserProfileWith(user: user, fullname: fullname, profileImageURL: userProfilePictureURL, maxDistance: Int64(self.distanceSlider.value), usertype: usertype)
                    
                }) { (hasFinishedURL) in
                    guard hasFinishedURL else {return}
                    completion(true)
                }
            })
        }
    }
    
    
    // MARK: - Delete Interest
    func presentDeleteInterestConformationAlert(completion: @escaping(_ success: Bool) -> Void) {
        let alert = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delte this interest?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            completion(true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Functions
    func setUpView() {
        adminPasswordTextfield.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        guard let user = UserController.shared.loadUserProfile() else {return}
        fullnameTextfield.text = user.fullname
        distanceSlider.setValue(Float(user.eventDistance), animated: false)
        maxLabelTextField.text = "\(user.eventDistance) mi"
        
        if user.usertype == UserType.leadCause.rawValue {
            areYouAnAdminLabel.isHidden = true
            activateAdminAccountButton.isHidden = true
            youAreAnAdminLabel.isHidden = false
        }
        
        profileImageView.image = UserController.shared.profilePicture
        
        // Set up the pop views
        activateAdminGroupView.layer.cornerRadius = 15
        successGroupView.layer.cornerRadius = 15
        finishedUpdatedProfileView.layer.cornerRadius = 15
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        cameraButton.isHidden = false
        
        // Update user success view
        self.finishedUpdatedProfileView.isHidden = true
        self.successImageView.isHidden = true
        self.uploadingProfileActivityMonitor.isHidden = true
        self.exitProfileUpdateView.isHidden = true
        self.uploadingProfileActivityMonitor.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
    }
    
    func fadeActivateAdminGroupIn() {
        activateAdminGroupView.alpha = 0
        self.activateAdminGroupView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.activateAdminGroupView.alpha = 1
            self.view.backgroundColor = UIColor.darkGray
        }
    }
    
    func fadeActivateAdminGroupOut() {
        activateAdminGroupView.alpha = 1
        
        UIView.animate(withDuration: 0.3) {
            self.activateAdminGroupView.alpha = 0
            self.activateAdminGroupView.isHidden = true
            self.view.backgroundColor = UIColor.white
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - Photo Methods
extension UpdateUserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Picking an iamge from libary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image: UIImage!
        
        self.profileImageView.image = nil
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = img
        } else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = img
        }
        
        // Assign the image in the delegate
        delegate?.photoSelectedWithVC(image)
        
        DispatchQueue.main.async {
            self.profileImageView.image = image
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
            self.profileImageView.clipsToBounds = true
        }
        self.changedProfilePicture = true
        picker.dismiss(animated: true,completion: nil)
    }
    
    private func presentCameraAndPhotoLibraryOption() {
        
        let actionSheet = UIAlertController(title: "Where do you want your photo from?", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            // Get access to the camara
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let libarayAction = UIAlertAction(title: "From library", style: .default) { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.modalPresentationStyle = .popover
                
                if let popoverPresentation = imagePicker.popoverPresentationController {
                    popoverPresentation.sourceView = self.view
                    popoverPresentation.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY / 2, width: 0, height: 0)
                    popoverPresentation.permittedArrowDirections = .any
                }
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        if let popoverContoller = actionSheet.popoverPresentationController {
            popoverContoller.sourceView = self.view
            popoverContoller.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY / 2, width: 0, height: 0)
            popoverContoller.permittedArrowDirections = []
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libarayAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}


extension UpdateUserProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let password = adminPasswordTextfield.text else {return false}
        
        UserController.shared.confirmAdminPasswordWith(password: password ) { (success) in
            if success {
                guard let user = UserController.shared.loadUserProfile(),
                    let email = user.email,
                    let fullname = self.fullnameTextfield.text,
                    let image = self.profileImageView.image else {return}
                self.updateProfileWith(user: user, image: image, email: email, fullname: fullname)
                self.successGroupView.isHidden = false
            } else {
                self.incorrectPasswordMessage.isHidden = false
                self.adminPasswordTextfield.text = ""
            }
        }
        
        return true
    }
    
}
