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
    
    
    // Admin Group View Outlets
    @IBOutlet weak var activateAdminGroupView: UIView!
    @IBOutlet weak var adminPasswordTextfield: UITextField!
    @IBOutlet weak var incorrectPasswordMessage: UILabel!
    
    // Success Group view
    @IBOutlet weak var successGroupView: UIView!
    
    
    // MARK: - Properties
    var delegate: PhotoSelectedViewControllerDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func activateAdminAccountButtonPressed(_ sender: Any) {
        self.fadeActivateAdminGroupIn()
        
        activateAdminAccountButton.isHidden = true
        areYouAnAdminLabel.isHidden = true
        incorrectPasswordMessage.isHidden = true
        adminPasswordTextfield.text = ""
        cameraButton.isHidden = true
    }
    
    @IBAction func chooseProfileImageButtonPressed(_ sender: Any) {
        self.presentCameraAndPhotoLibraryOption()
    }
    
    
    @IBAction func dismissActivateAdminGroupButtonPressed(_ sender: Any) {
        self.activateAdminGroupView.isHidden = true
        areYouAnAdminLabel.isHidden = false
        activateAdminAccountButton.isHidden = false
        cameraButton.isHidden = false
        
        self.fadeActivateAdminGroupOut()
        view.endEditing(true)
    }
    
    @IBAction func dismissSuccessAdminView(_ sender: Any) {
        presentAdminTabBarVC(viewController: self)
    }
    
    
    @IBAction func sumbitAdminPasswordButtonPressed(_ sender: Any) {
        guard let password = adminPasswordTextfield.text else {return}
        
        UserController.shared.confirmAdminPasswordWith(password: password ) { (success) in
            if success {
                self.successGroupView.isHidden = false
            } else {
              self.incorrectPasswordMessage.isHidden = false
            }
        }
    }
    
    @IBAction func sliderValuedChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.maxLabelTextField.text = "\(Int(sender.value)) mi"
        }
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
            areYouAnAdminLabel.text = "You're An Admin"
            activateAdminAccountButton.isHidden = true
        }
        
        // Set up the pop views
        activateAdminGroupView.layer.cornerRadius = 15
        successGroupView.layer.cornerRadius = 15
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        cameraButton.isHidden = false
        
    }
    
    func fadeActivateAdminGroupIn() {
        activateAdminGroupView.alpha = 0
        self.activateAdminGroupView.isHidden = false
        
        UIView.animate(withDuration: 0.5) {
            self.activateAdminGroupView.alpha = 1
            self.view.backgroundColor = UIColor.darkGray
        }
    }
    
    func fadeActivateAdminGroupOut() {
        activateAdminGroupView.alpha = 1
        
        UIView.animate(withDuration: 0.5) {
            self.activateAdminGroupView.alpha = 0
            self.activateAdminGroupView.isHidden = false
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
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = img
        } else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = img
        }
        
        picker.dismiss(animated: true,completion: nil)
        // Assign the iamge in the delegate
        delegate?.photoSelectedWithVC(image)
        profileImageView.image = image
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
    }
    
    private func presentCameraAndPhotoLibraryOption() {
        
        let actionSheet = UIAlertController(title: "Where do you want your photo from?", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            // Get access to the camara
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
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
                self.successGroupView.isHidden = false
            } else {
                self.incorrectPasswordMessage.isHidden = false
            }
        }
        
        return true
    }
    
}
